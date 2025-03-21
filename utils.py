import ollama
from flask import jsonify
import os

def get_model_list():
    """
    Get the list of available models from the Ollama API.
    """
    models_data = ollama.list()
    models = [model['model'] for model in models_data['models']]
    # Remove ':latest' from the model names
    models = [models.replace(':latest', '') for models in models]
    return models

def load_model(model_name, keep_alive=True, timeout="5m"):
    """
    Load a model from the Ollama API. (with an empty request)
    """
    if keep_alive:
        res = ollama.generate(model_name, prompt="", keep_alive=-1)

    else:
        res = ollama.generate(model_name, prompt="", keep_alive=timeout)
    return res

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

# A class to manipulate files in the system
class FileHandler:
    def __init__(self) -> None:
        pass

    # check if a file exists
    def file_exists(self, path):
        return os.path.exists(path)

    # check if a file is a file
    def is_file(self, path):
        return os.path.isfile(path)

    # check if a file is a directory
    def is_dir(self, path):
        return os.path.isdir(path)

    def delete_file(self, path):
        if self.file_exists(path) and self.is_file(path):
            os.remove(path)
            return True
        return False
    
    # delete all files in a directory
    def delete_files_in_dir(self, path):
        if self.is_dir(path):
            files = os.listdir(path)
            for file in files:
                self.delete_file(os.path.join(path, file))
            return True
        return False
