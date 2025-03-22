# NoxDomus

## Requirements

- [Ollama](https://github.com/ollama/ollama): LLM framework.
    - Pull `phi3.5` with `ollama pull phi3.5`.
    - Other models can be used, but the code will need to be adapted, by changing the model name in the api call (in EnigmeAPI.gd).

- Python3 and some packages: `pip install -r requirements.txt`

- [Godot](https://godotengine.org/): Game engine

- [comfy-cli](https://github.com/Comfy-Org/comfy-cli): Command Line Interface for Managing ComfyUI (Optional)
    - comfy-cli allows you to easily lauch the ComfyUI api server, and to manage other aspects of ComfyUI, as well as to install ComfyUI itself.

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI): Diffusion model GUI and api

- Additional requirements for ComfyUI:
    - [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Manager): extension for ComfyUI (Optional but recommended)
        - It allows to easily manage and install new nodes and models.
        - It should be installed with comfy-cli.
    - [Masquerade Nodes](https://github.com/BadCafeCode/masquerade-nodes-comfyui): mask-related nodes for ComfyUI
    - [Tiled KSampler](https://github.com/FlyingFireCo/tiled_ksampler) (for tiled images generation)

## Installation

Clone the repository and install the requirements.
        
## Usage

- `python3 main.py` to run ComfyUI api server (in ComfyUI directory). Or use comfy-cli. `comfy lauch --background`. Background runnning can be stopped with `comfy stop`.
- `python3 api.py` to run NoxDomus api server
- Lauch the game in Godot. The game will connect to the NoxDomus api server via port 5000.

## Documentation

The API in `api.py` is well commented.
The game is also commented. It is recommanded to launch Godot to read the code.
