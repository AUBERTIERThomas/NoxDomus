# NoxDomus

## Requirements

- [Ollama](https://github.com/ollama/ollama): LLM framework.
Pull `phi3.5` with `ollama pull phi3.5`.
Other models can be used, but the code will need to be adapted, by changing the model name in the api call (in EnigmeAPI.gd).

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI): Diffusion model GUI and api
Install additional nodes for ComfyUI.

- Python3 and some libraries: `pip install -r requirements.txt`

- [Godot](https://godotengine.org/): Game engine (for development only)

## Usage

- `python3 main.py` to run ComfyUI api server (in ComfyUI directory)
- `python3 api.py` to run NoxDomus api server
- Lauch the game

## Documentation

The API in `api.py` is well commented and should be easy to understand.
