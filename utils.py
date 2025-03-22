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
    """
    Enum class for status values to return in the JSON response.
    """
    OK = "ok"
    ERROR = "error"

# a class for a json to return in case of error to the user
class ErrorJson:
    """
    A class to return an error message to the client in JSON format.
    """
    def __init__(self, message, status=Status.ERROR):
        self.message = message
        self.status = status

    def __str__(self):
        return self.message

    def to_error(self):
        """
        Change the status to `error`.
        """
        self.status = Status.ERROR

    def to_ok(self):
        """
        Change the status to `ok`.
        """
        self.status = Status.OK

    def to_dict(self):
        return {
            "status": self.status,
            "message": self.message
        }
    
    def to_json(self):
        return jsonify(self.to_dict())

    def to_json_c(self, code):
        """
        Return the JSON response with a specific status code.
        """
        return jsonify(self.to_dict()), code

class FileHandler:
    """
    A class to handle files in the system.
    """
    def __init__(self) -> None:
        pass

    def file_exists(self, path):
        """
        Check if a file exists.
        """
        return os.path.exists(path)

    def is_file(self, path):
        """
        Check if a file is a file.
        """
        return os.path.isfile(path)

    def is_dir(self, path):
        """
        Check if a file is a directory.
        """
        return os.path.isdir(path)

    def delete_file(self, path):
        """
        Delete a file if it exists and is a file.

        Returns True if the file was deleted, False otherwise.
        """
        if self.file_exists(path) and self.is_file(path):
            os.remove(path)
            return True
        return False
    
    def delete_files_in_dir(self, path):
        """
        Delete all files in a directory.
        
        Returns True if the files were deleted, False otherwise.
        """
        if self.is_dir(path):
            files = os.listdir(path)
            for file in files:
                self.delete_file(os.path.join(path, file))
            return True
        return False
