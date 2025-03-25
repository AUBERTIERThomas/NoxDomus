from flask import Flask, jsonify, request

from AI.Riddles.riddles import RiddlesHandler
from AI.Riddles.question_validator import check_answer
from AI.MultipleChoice.qcms import QcmHandler

from AI.commentary import comment, Commentary

from AI.Images.gen_img import Comfyui
from AI.Images.prompt_enhancer import enhance_prompt

from utils import Status, get_model_list, is_boolean, ErrorJson, FileHandler, load_model

available_models = get_model_list()

app = Flask("NoxDomusAPI")
app.config["DEBUG"] = True
riddles = RiddlesHandler()
qcms = QcmHandler()
comfyui_img_inpaint = Comfyui('AI/Images/Workflows/inpaint-wall.json')
comfyui_img = Comfyui('AI/Images/Workflows/seamless-textures-wall.json')

@app.route('/', methods=['GET'])
def home():

    with open('home.html', 'r') as file:
        page = file.read()
    return page

@app.route('/en', methods = ['GET'])
def home_en():

    with open('home-en.html', 'r') as file:
        page = file.read()
    return page

###############################################################################

@app.route('/riddle/generate', methods=['GET'])
def get_riddle():
    """
    Get a random riddle from the riddles pool.
    
    Optional parameters:
    - authorize_repetition: True or False. Default is False.
    """
    auth_repetition= False
    if 'authorize_repetition' in request.args:
        # Check if the parameter is a boolean
        if is_boolean(request.args['authorize_repetition']):
            auth_repetition = (request.args['authorize_repetition'].lower() == 'true')
        else:
            return ErrorJson('authorize_repetition must be a boolean').to_json_c(400)
    riddle = riddles.generate_random_riddle(auth_repetition)
    return jsonify(riddle.model_dump())


@app.route('/riddle/verify', methods=['GET'])
def verify_riddle():
    """
    Verify if the user's answer to a given question is correct.

    Mandatory parameters:
    - question: the question
    - correct_answer: the correct answer
    - user_answer: the user's answer

    Optional parameters:
    - model: the model used to check the answer. Default is phi3.5 (in ollama).
    - nb_checks: the number of checks to perform. Default is 3. Must be between 1 and 10.
        (C'est complètement arbitraire, mais c'est pour éviter de faire trop de checks)
    """
    if 'question' in request.args and 'correct_answer' in request.args and 'user_answer' in request.args:
        question = request.args['question']
        correct_answer = request.args['correct_answer']
        user_answer = request.args['user_answer']
    else:
        return ErrorJson("question, correct_answer and user_answer are required parameters").to_json_c(400)

    # Optional parameters
    model = request.args.get('model', 'phi3.5')
    print("Model ", model)
    nb_checks = int(request.args.get('nb_checks', 3))

    if nb_checks < 1 or nb_checks > 10:
        return ErrorJson("nb_checks must be between 1 and 10").to_json_c(400)
    if model not in available_models:
        return ErrorJson(f"Model {model} is not available. Available models are: {available_models}").to_json_c(400)

    print(f'question: {question}, correct_answer: {correct_answer}, user_answer: {user_answer}, model: {model}, nb_checks: {nb_checks}')

    check = check_answer(question, correct_answer, user_answer, model, nb_checks)
    return jsonify({'is_right': check})

@app.route('/load_model', methods=['GET'])
def load_model_in_memory():
    """
    Load an LLM model from Ollama in memory.
    Can be loaded indefinitely or for a given time.
    To stop the model, set a small time (ex: 1s) and keep_alive to False.

    Mandatory parameters:
    - model: the model to load

    Optional parameters:
    - keep_alive: True or False. Default is False.
    - time: the time to keep the model in memory. Default is 5 min if keep_alive is False.
        If keep_alive is True, this parameter is ignored.
        format is the same as the one used in the Ollama API.
        ex: 5 minutes: "5m"
    """

    if 'model' not in request.args:
        return ErrorJson('model is a required parameter').to_json_c(400)
    model = request.args['model']

    if model not in available_models:
        return ErrorJson(f"Model {model} is not available. Available models are: {available_models}").to_json_c(400)

    keep_alive = False
    if 'keep_alive' in request.args:
        if is_boolean(request.args['keep_alive']):
            keep_alive = (request.args['keep_alive'].lower() == 'true')
        else:
            return ErrorJson('keep_alive must be a boolean').to_json_c(400)

    if 'time' in request.args:
        time = request.args['time']
    else:
        time = '5m'

    res = load_model(model, keep_alive, time)

    # On utilise pas res. C'est pour vérifier que le modèle est bien chargé
    return ErrorJson(f"Model {model} loaded in memory", Status.OK).to_json_c(200)

@app.route('/riddle/number', methods=['GET'])
def get_number_of_riddles():
    """
    Get the number of riddles in the riddles pool.
    """
    return jsonify({'number_of_riddles': riddles.get_number_of_riddles()})

@app.route('/qcm/generate', methods=['GET'])
def get_qcm():
    """
    Get a random qcm from the qcm pool.
    
    Optional parameters:
    - authorize_repetition: True or False. Default is False.
    """
    auth_repetition= False
    if 'authorize_repetition' in request.args:
        # Check if the parameter is a boolean
        if is_boolean(request.args['authorize_repetition']):
            auth_repetition = (request.args['authorize_repetition'].lower() == 'true')
        else:
            return ErrorJson('authorize_repetition must be a boolean').to_json_c(400)
    qcm = qcms.generate_random_qcm(auth_repetition)
    return jsonify(qcm.model_dump())

@app.route('/qcm/number', methods=['GET'])
def get_number_of_qcms():
    """
    Get the number of qcms in the qcm pool.
    """
    return jsonify({'number_of_qcms': qcms.get_number_of_qcms()})

################################################################################

@app.route('/alexandre/astier', methods=['GET'])
def get_commentary():
    """
    Get a commentary of a game action.

    Mandatory parameters:
    - question: the question
    - correct_answer: the correct answer
    - user_answer: the user's answer
    - is_user_right: True or False

    Optional parameters:
    - model: the model used to check the answer. Default is phi3.5 (in ollama).
    """

    if 'question' not in request.args:
        return ErrorJson('question is a required parameter').to_json_c(400)
    question = request.args['question']

    if 'correct_answer' not in request.args:
        return ErrorJson('correct_answer is a required parameter').to_json_c(400)
    correct_answer = request.args['correct_answer']

    if 'user_answer' not in request.args:
        return ErrorJson('user_answer is a required parameter').to_json_c(400)
    user_answer = request.args['user_answer']

    if 'is_user_right' not in request.args:
        return ErrorJson('is_user_right is a required parameter').to_json_c(400)
    # Check if the parameter is a Boolean
    if is_boolean(request.args['is_user_right']):
        is_user_right = (request.args['is_user_right'].lower() == 'true')
    else:
        return ErrorJson('is_user_right must be a boolean').to_json_c(400)
    
    model = 'phi3.5'
    if 'model' in request.args:
        model = request.args['model']

    response = comment(is_user_right, question, correct_answer, user_answer, model)

    return jsonify(response.model_dump())


################################################################################

@app.route('/enhance_prompt', methods = ['GET'])
def prompt_enhancer():
    """
    Enhance a prompt with the llm model using the prompt in `AI/Prompts/prompt_enhancer.txt`.

    Mandatory parameters:
    - prompt: the prompt to enhance

    Optional parameters:
    - model: the model to use. Default is phi3.5.
    """

    if 'prompt' not in request.args:
        return ErrorJson('prompt is a required parameter').to_json_c(400)
    prompt = request.args['prompt']

    model = 'phi3.5'
    if 'model' in request.args:
        model = request.args['model']

    enhanced = enhance_prompt(prompt, model)
    
    # Additional manual enhancing
    enhanced.enhanced_prompt += ", (masterpiece), (4K), horror style, realisitic, (intricately imbricated within a crumbling wall), evoking a dark and eerie atmosphere, touch of the macabre"

    return jsonify(enhanced.model_dump())

@app.route('/image/inpaint', methods = ['GET'])
def inpaint():
    """
    Inpaint a given image with a given mask with a given prompt.
    If a file with the same filename already exists, it will be overwritten.

    Mandatory parameters:
    - img_path: the path to the image to inpaint on 
    - mask_path: the path to the mask to use
    - positive_prompt: the prompt to use
    - filename: the prefix to use for the output filename
    
    Optional parameters:
    - output_folder: the folder where the image will be saved. Default is `Output`
    - seed: the seed for the random generation. (useful for reproducibility)
        If not provided, a random seed will be used.
    - checkpoint: the name of the checkpoint to use. (not recommended changing it)
    - negative_prompt: the negative prompt
    """

    if 'img_path' not in request.args:
        return ErrorJson('img_path is a required parameter').to_json_c(400)
    img_path = request.args['img_path']
    comfyui_img_inpaint.load_image('17', img_path)
    if 'mask_path' not in request.args:
        return ErrorJson('mask_path is a required parameter').to_json_c(400)
    mask_path = request.args['mask_path']
    comfyui_img_inpaint.load_image('58', mask_path)
    if 'positive_prompt' not in request.args:
        return ErrorJson('positive_prompt is a required parameter').to_json_c(400)
    positive_prompt = request.args['positive_prompt']
    comfyui_img_inpaint.set_positive_prompt('5', positive_prompt)
    if 'filename' not in request.args:
        return ErrorJson('filename is a required parameter').to_json_c(400)
    filename = request.args['filename']

    if 'negative_prompt' in request.args:
        comfyui_img_inpaint.set_negative_prompt('6', request.args['negative_prompt'])

    if 'seed' in request.args:
        comfyui_img_inpaint.set_seed('9', request.args['seed'])
    else:
        comfyui_img.set_random_seed('9')

    if 'checkpoint' in request.args:
        comfyui_img_inpaint.set_ckpt('3', request.args['checkpoint'])

    if 'output_folder' in request.args:
        output_folder = request.args['output_folder']
    else:
        output_folder = 'Output'

    print("Starting ComfyUI inpainting process")
    try:
        # Set a timeout for the request
        # success = comfyui_img_inpaint.run_and_display()
        success = comfyui_img_inpaint.run_and_save(filename, output_folder)
        print(f"ComfyUI process completed with result: {success}")
        
        if success:
            # Not an error but flemme, status aussi peut etre OK
            return ErrorJson('Image generated successfully', Status.OK).to_json_c(200)
        else:
            print("ComfyUI process failed")
            return ErrorJson('Failed to generate image').to_json_c(500)

    except Exception as e:
        print(f"Exception during image generation: {str(e)}")
        return ErrorJson(f'Exception during image generation: {str(e)}').to_json_c(500)


@app.route('/image/generate', methods = ['GET'])
def launch_genimg():
    """
    Generate an image from a given prompt, using the workflow in
    `AI/Images/Workflows/seamless_textures.json` (numéros nodes hardcodés)

    Mandatory parameters:
    - name: the name of the image

    Optional parameters:
    - output_folder: the folder where the image will be saved. Default is `Output`
    - positive_prompt: the positive prompt
    - negative_prompt: the negative prompt
    - seed: the seed for the random generation. (useful for reproducibility)
        If not provided, a random seed will be used.
    - checkpoint: the name of the checkpoint to use. (not recommended changing it)
        Default is `SDXL/sd_xl_base_1.0.safetensors`
    - width: the width of the image. Default is 1024.
    - height: the height of the image. Default is 1024. (set to 2048 used for walls)
    - seamless_xaxis: True or False. Default is False.
    - seamless_yaxis: True or False. Default is False.
    """

    if 'positive_prompt' in request.args:
        comfyui_img.set_positive_prompt('16', request.args['positive_prompt'])

    if 'negative_prompt' in request.args:
        comfyui_img.set_negative_prompt('7', request.args['negative_prompt'])

    if 'seed' in request.args:
        comfyui_img.set_seed('11', request.args['seed'])
    else:
        comfyui_img.set_random_seed('11')
    
    if 'checkpoint' in request.args:
        comfyui_img.set_ckpt('4', request.args['checkpoint'])

    if 'width' in request.args:
        comfyui_img.set_img_width('5', request.args['width'])
    else:
        comfyui_img.set_img_width('5', 1024)

    if 'height' in request.args:
        comfyui_img.set_img_height('5', request.args['height'])
    else:
        comfyui_img.set_img_height('5', 1024)

    if 'seamless_xaxis' in request.args:
        if is_boolean(request.args['seamless_xaxis']):
            comfyui_img.seamless_xaxis('11', request.args['seamless_xaxis'].lower() == 'true')
        else:
            return ErrorJson('seamless_xaxis must be a boolean').to_json_c(400)
    else:
        comfyui_img.seamless_xaxis('11', False)

    if 'seamless_yaxis' in request.args:
        if is_boolean(request.args['seamless_yaxis']):
            comfyui_img.seamless_yaxis('11', request.args['seamless_yaxis'].lower() == 'true')
        else:
            return ErrorJson('seamless_yaxis must be a boolean').to_json_c(400)
    else:
        comfyui_img.seamless_yaxis('11', False)

    if 'name' not in request.args:
        return ErrorJson('name is a required parameter').to_json_c(400)
    name = request.args['name']

    if 'output_folder' in request.args:
        output_folder = request.args['output_folder']
    else:
        output_folder = 'Output'

    print("Starting ComfyUI image generation process")
    try:
        # Set a timeout for the request
        # success = comfyui_img.run_and_display()
        success = comfyui_img.run_and_save(name, output_folder)
        print(f"ComfyUI process completed with result: {success}")
        
        if success:
            return ErrorJson('Image generated successfully', Status.OK).to_json_c(200)
        else:
            print("ComfyUI process failed")
            return ErrorJson('Failed to generate image').to_json_c(500)

    except Exception as e:
        print(f"Exception during image generation: {str(e)}")
        return ErrorJson(f'Exception during image generation: {str(e)}').to_json_c(500)

# @app.route('/image/wall', methods = ['GET'])
# def launch_genimg_wall():
#     """
#     Generate an image of a wall with seamless left and right sides.
#     """
#
#     return ErrorJson("Not implemented yet").to_json_c(501)

# @app.route('/image/floor', methods = ['GET'])
# def launch_genimg_floor():
#     """
#     Generate an tiled image for a floor.
#     """
#
#     return ErrorJson("Not implemented yet").to_json_c(501)

# @app.route('/image/ceiling', methods = ['GET'])
# def launch_genimg_ceiling():
#     """
#     Generate an image for a ceiling.
#     """
#
#     return ErrorJson("Not implemented yet").to_json_c(501)
#
# @app.route("/image/inpaint", methods = ['GET'])
# def launch_genimg_inpaint():
#     """
#     Generate an inpainted image from a given image.
#     """
#     
#     return ErrorJson("Not implemented yet").to_json_c(501)

@app.route('/image/delete', methods = ['DELETE'])
def delete_image():
    """
    Delete an image that was generated.

    Mandatory parameters:
    - filename: the name of the image to delete
    
    Optional parameters:
    - folder: the folder of the image to delete. Default is `Output`
    """
    
    if 'folder' in request.args:
        folder = request.args['folder']
    else:
        folder = 'Output'

    if 'filename' not in request.args:
        return ErrorJson('filename is a required parameter').to_json_c(400)
    filename = request.args['filename']

    path = f"{folder}/{filename}"
    
    file_handler = FileHandler()
    
    if file_handler.delete_file(path):
        return ErrorJson(f"Deleted file: {path}", Status.OK).to_json_c(200)
    return ErrorJson(f"Failed to delete file: {path}").to_json_c(500)

@app.route('/image/delete_all', methods = ['DELETE'])
def delete_all_images():
    """
    Delete all images that were generated in the current session.

    Optional parameters:
    - current_session: True or False. Default is True.
        If set to False, all images in the `Output` folder will be deleted.
        If set to True, only images generated in the current session will be deleted.
    - folder: the folder where the images are stored. Default is `Output`
    """

    file_handler = FileHandler()
    
    current_session = True
    if 'current_session' in request.args:
        if is_boolean(request.args['current_session']):
            current_session = (request.args['current_session'].lower() == 'true')
        else:
            return ErrorJson('current_session must be a boolean').to_json_c(400)

    if 'folder' in request.args:
        folder = request.args['folder']
    else:
        folder = 'Output'

    if not current_session:
        # Delete all files in the Output folder
        rep = file_handler.delete_files_in_dir(folder)
        if rep:
            return ErrorJson("Deleted all files in the Output folder", Status.OK).to_json_c(200)
        return ErrorJson("Failed to delete all files in the Output folder").to_json_c(500)


    # Case of deleting only images generated in the current session
    
    images = comfyui_img.saved_images + comfyui_img_inpaint.saved_images

    for image in images:
        res = file_handler.delete_file(image)
        if not res:
            return ErrorJson(f"Failed to delete file: {image}").to_json_c(500)

    return ErrorJson("Deleted all images generated in the current session", Status.OK).to_json_c(200)



################################################################################

if __name__ == '__main__':
    app.run()
