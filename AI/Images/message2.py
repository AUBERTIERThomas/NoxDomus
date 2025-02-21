import subprocess
import os
import json
import time
import requests
from urllib import request

# Paths (Update this to your actual ComfyUI installation path)
COMFYUI_PATH = "/home/niccolo/ComfyUI"  # Change this to your real path
PYTHON_EXE = "python3"  # Use system-wide Python 3
SCRIPT = "main.py"  # ComfyUI's main script
API_URL = "http://127.0.0.1:8188/prompt"

# Predefined Workflow
prompt_text = """
{
    "3": {
        "class_type": "KSampler",
        "inputs": {
            "cfg": 8,
            "denoise": 1,
            "latent_image": [
                "5",
                0
            ],
            "model": [
                "4",
                0
            ],
            "negative": [
                "7",
                0
            ],
            "positive": [
                "6",
                0
            ],
            "sampler_name": "euler",
            "scheduler": "normal",
            "seed": 8566257,
            "steps": 20
        }
    },
    "4": {
        "class_type": "CheckpointLoaderSimple",
        "inputs": {
            "ckpt_name": "v1-5-pruned-emaonly-fp16.safetensors"
        }
    },
    "5": {
        "class_type": "EmptyLatentImage",
        "inputs": {
            "batch_size": 1,
            "height": 512,
            "width": 512
        }
    },
    "6": {
        "class_type": "CLIPTextEncode",
        "inputs": {
            "clip": [
                "4",
                1
            ],
            "text": "masterpiece best quality girl"
        }
    },
    "7": {
        "class_type": "CLIPTextEncode",
        "inputs": {
            "clip": [
                "4",
                1
            ],
            "text": "bad hands"
        }
    },
    "8": {
        "class_type": "VAEDecode",
        "inputs": {
            "samples": [
                "3",
                0
            ],
            "vae": [
                "4",
                2
            ]
        }
    },
    "9": {
        "class_type": "SaveImage",
        "inputs": {
            "filename_prefix": "ComfyUI",
            "images": [
                "8",
                0
            ]
        }
    }
}
"""

def start_comfyui():
    """Starts ComfyUI in a background process and waits until it's ready."""
    os.chdir(COMFYUI_PATH)
    command = [PYTHON_EXE, SCRIPT]  # Removed Windows-specific flags
    subprocess.Popen(command)
    print("Starting ComfyUI...")

    # Wait until the API is available
    for i in range(30):  # Try for 30 seconds
        try:
            response = requests.get("http://127.0.0.1:8188")
            if response.status_code == 200:
                print("ComfyUI API is ready!")
                return
        except requests.ConnectionError:
            pass
        print(f"Waiting for ComfyUI to start... ({i+1}/30)")
        time.sleep(1)

    print("Error: ComfyUI did not start within 30 seconds.")
    exit(1)

def queue_prompt(prompt):
    """Sends a workflow JSON to the ComfyUI API."""
    p = {"prompt": prompt}
    data = json.dumps(p).encode('utf-8')
    req = request.Request(API_URL, data=data)
    
    try:
        response = request.urlopen(req)
        print("Workflow submitted successfully!")
        print(response.read().decode())
    except Exception as e:
        print(f"Error submitting workflow: {e}")

if __name__ == "__main__":
    start_comfyui()

    # Load and modify workflow
    prompt = json.loads(prompt_text)
    
    # Modify parameters dynamically
    prompt["6"]["inputs"]["text"] = "Terminator in School"  # Change prompt text
    prompt["3"]["inputs"]["seed"] = 5  # Change seed
    prompt["9"]["inputs"]["filename_prefix"] = "nom"
    
    print("Submitting workflow with modified parameters...")
    queue_prompt(prompt)
