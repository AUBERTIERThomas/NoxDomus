import ollama
from flask import jsonify

def get_model_list():
    """
    Get the list of available models from the Ollama API.
    """
    models_data = ollama.list()
    models = [model['model'] for model in models_data['models']]
    # Remove ':latest' from the model names
    models = [models.replace(':latest', '') for models in models]
    return models

def is_boolean(value):
    """
    Check if a string is a boolean.
    """
    return value.lower() in ['true', 'false']

# class enum to have to values: error and ok
class Status:
    OK = "ok"
    ERROR = "error"

# a class for a json to return in case of error to the user
class ErrorJson:
    def __init__(self, message, status=Status.ERROR):
        self.message = message
        self.status = status

    def __str__(self):
        return self.message

    # change status to error
    def to_error(self):
        self.status = Status.ERROR

    # change status to ok
    def to_ok(self):
        self.status = Status.OK

    def to_dict(self):
        return {
            "status": self.status,
            "message": self.message
        }
    
    def to_json(self):
        return jsonify(self.to_dict())

    def to_json_c(self, code):
        return jsonify(self.to_dict()), code

    

    
    
