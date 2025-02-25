from flask import Flask, jsonify, request
import ollama

from Riddles.riddles import RiddlesHandler
from Riddles.question_validator import check_answer

app = Flask("NoxDomusAPI")
riddles = RiddlesHandler()

def get_model_list():
    """
    Get the list of available models from the Ollama API.
    """
    models_data = ollama.list()
    models = [model['model'] for model in models_data['models']]
    # Remove ':latest' from the model names
    models = [models.replace(':latest', '') for models in models]
    return models

available_models = get_model_list()

################################################################################
# Routes

@app.route('/riddle/<int:authorize_repetition>', methods=['GET'])
def get_riddle(authorize_repetition):
    """
    Get a random riddle from the riddles pool.
    
    <authorize_repetition> is a boolean that indicates if the same riddle can be
    generated multiple times in a row.
    """
    if authorize_repetition not in [0, 1]:
        return jsonify(
            {
                'error_message': 'authorize_repetition has to be 0 (False) or 1 (True)'
            })

    riddle = riddles.generate_random_riddle(bool(authorize_repetition))
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
    - model: the model used to check the answer. Default is mistral. (in ollama)
    - nb_checks: the number of checks to perform. Default is 3. Must be between 1 and 10.
    """

    if 'question' not in request.args or 'correct_answer' not in request.args or 'user_answer' not in request.args:
        return jsonify(
            {
                'error_message': 'question, correct_answer and user_answer are required parameters',
            })
    
    question = request.args['question']
    correct_answer = request.args['correct_answer']
    user_answer = request.args['user_answer']

    # Optional parameters
    model = request.args.get('model', 'mistral')
    nb_checks = int(request.args.get('nb_checks', 3))

    if nb_checks < 1 or nb_checks > 10:
        return jsonify(
            {
                'error_message': 'nb_checks has to be between 1 and 10'
            })
    if model not in available_models:
        return jsonify(
            {
                'error_message': f'{model} is not a valid model. Available models are: ' + ', '.join(available_models)
            })


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

if __name__ == '__main__':
    app.run()
    # Warning quand on le lance qui dit ceci est un serveur test, mais c'est
    # Parcequ'il est capable de gérer une seule requete à la fois
