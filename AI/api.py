from flask import Flask, jsonify, request

from Riddles.riddles import RiddlesHandler
from Riddles.question_validator import check_answer

app = Flask("NoxDomusAPI")
riddles = RiddlesHandler('Riddles/creation/riddles.csv')

# Modèles qui peuvent être utilisés pour vérifier les réponses
# Il faut qu'il soit téléchargé dans ollama (ici pc de niccolo)

# available_models = ['mistral']
available_models = ['mistral', 'qwen2.5', 'qwen2.5:0.5b', 'qwen2.5:3b', 'qwen2.5:1.5b', 'llama3.1', 'llama3.2', 'llama3.2:1b', 'granite3.1-moe', 'granite3.1-moe:1b']

@app.route('/riddle/<int:authorize_repetition>', methods=['GET'])
def get_riddle(authorize_repetition):
    if authorize_repetition not in [0, 1]:
        return jsonify(
            {
                'error_message': 'authorize_repetition has to be 0 (False) or 1 (True)'
            })

    riddle = riddles.generate_random_riddle(bool(authorize_repetition))
    return jsonify(riddle.dict())


@app.route('/riddle/verify', methods=['GET'])
def verify_riddle():
    if 'question' not in request.args or 'correct_answer' not in request.args or 'user_answer' not in request.args:
        return jsonify(
            {
                'error_message': 'question, correct_answer and user_answer are required parameters',
                'usage': "For example: /riddle/verify?question=What is the capital of France?&correct_answer=Paris&user_answer=C'est Marseille bébé",
                'optional_parameters': {
                    'model': 'The model used to check the answer. Default is mistral. Available models are: ' + ', '.join(available_models),
                    'nb_checks': 'The number of checks to perform. Default is 3. Must be between 1 and 10.'
                }
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

if __name__ == '__main__':
    app.run()
    # Warning quand on le lance qui dit ceci est un serveur test, mais c'est
    # Parcequ'il est capable de gérer une seule requete à la fois
