from flask import Flask, jsonify, request

from AI.Riddles.riddles import RiddlesHandler
from AI.Riddles.question_validator import check_answer

from AI.Images.gen_img import Comfyui

from utils import Status, get_model_list, is_boolean, ErrorJson

available_models = get_model_list()

app = Flask("NoxDomusAPI")
app.config["DEBUG"] = True
riddles = RiddlesHandler()
comfyui_img = Comfyui('AI/Images/Workflows/seamless_textures.json')

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

@app.route('/riddle/number', methods=['GET'])
def get_number_of_riddles():
    """
    Get the number of riddles in the riddles pool.
    """
    return jsonify({'number_of_riddles': riddles.get_number_of_riddles()})

################################################################################

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

@app.route('/image/wall', methods = ['GET'])
def launch_genimg_wall():
    """
    Generate an image of a wall with seamless left and right sides.
    """

    return ErrorJson("Not implemented yet").to_json_c(501)

@app.route('/image/floor', methods = ['GET'])
def launch_genimg_floor():
    """
    Generate an tiled image for a floor.
    """

    return ErrorJson("Not implemented yet").to_json_c(501)

@app.route('/image/ceiling', methods = ['GET'])
def launch_genimg_ceiling():
    """
    Generate an image for a ceiling.
    """

    return ErrorJson("Not implemented yet").to_json_c(501)

@app.route("/image/inpaint", methods = ['GET'])
def launch_genimg_inpaint():
    """
    Generate an inpainted image from a given image.
    """
    
    return ErrorJson("Not implemented yet").to_json_c(501)

@app.route('/image/delete', methods = ['DELETE'])
def delete_image():
    """
    Delete an image that was generated.
    """

    return ErrorJson("Not implemented yet").to_json_c(501)

@app.route('/image/delete_all', methods = ['DELETE'])
def delete_all_images():
    """
    Delete all images that were generated.
    """

    return ErrorJson("Not implemented yet").to_json_c(501)

################################################################################

if __name__ == '__main__':
    app.run()
