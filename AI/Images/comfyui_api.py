# Majority of the code is from ComfyUI's example code + extra bits
#
#This is an example that uses the websockets api to know when a prompt execution is done
#Once the prompt execution is done it downloads the images using the /history endpoint

import websocket #NOTE: websocket-client (https://github.com/websocket-client/websocket-client)
import uuid
import json
import urllib.request
import urllib.parse
import requests

server_address = "127.0.0.1:8188"
client_id = str(uuid.uuid4())

def queue_prompt(prompt):
    p = {"prompt": prompt, "client_id": client_id}
    data = json.dumps(p).encode('utf-8')
    req =  urllib.request.Request("http://{}/prompt".format(server_address), data=data)
    return json.loads(urllib.request.urlopen(req).read())

def get_image(filename, subfolder, folder_type):
    data = {"filename": filename, "subfolder": subfolder, "type": folder_type}
    url_values = urllib.parse.urlencode(data)
    with urllib.request.urlopen("http://{}/view?{}".format(server_address, url_values)) as response:
        return response.read()

def get_history(prompt_id):
    with urllib.request.urlopen("http://{}/history/{}".format(server_address, prompt_id)) as response:
        return json.loads(response.read())

# def get_images(ws, prompt):
#     prompt_id = queue_prompt(prompt)['prompt_id']
#     output_images = {}
#     while True:
#         ws.settimeout(20)
#         out = ws.recv()
#         if isinstance(out, str):
#             message = json.loads(out)
#             if message['type'] == 'executing':
#                 data = message['data']
#                 if data['node'] is None and data['prompt_id'] == prompt_id:
#                     break #Execution is done
#         else:
#             # If you want to be able to decode the binary stream for latent previews, here is how you can do it:
#             # bytesIO = BytesIO(out[8:])
#             # preview_image = Image.open(bytesIO) # This is your preview in PIL image format, store it in a global
#             continue #previews are binary data

#     history = get_history(prompt_id)[prompt_id]
#     for node_id in history['outputs']:
#         node_output = history['outputs'][node_id]
#         images_output = []
#         if 'images' in node_output:
#             for image in node_output['images']:
#                 image_data = get_image(image['filename'], image['subfolder'], image['type'])
#                 images_output.append(image_data)
#         output_images[node_id] = images_output

#     return output_images

def get_images(ws, prompt):
    print("Starting get_images function")
    try:
        print("Queueing prompt")
        prompt_id = queue_prompt(prompt)['prompt_id']
        print(f"Prompt queued with ID: {prompt_id}")
        
        output_images = {}
        print("Waiting for execution to complete")
        
        while True:
            print("Waiting for message from websocket...")
            try:
                # Set a timeout for receiving messages
                ws.settimeout(2) # second timeout for each message
                out = ws.recv()
                print(f"Received message type: {type(out)}")
                
                if isinstance(out, str):
                    message = json.loads(out)
                    print(f"Message content: {message['type']}")
                    
                    if message['type'] == 'executing':
                        data = message['data']
                        print(f"Execution data: node={data['node']}, prompt_id={data['prompt_id']}")
                        
                        if data['node'] is None and data['prompt_id'] == prompt_id:
                            print("Execution is complete, breaking loop")
                            break  # Execution is done
                else:
                    # Binary data (preview)
                    print("Received binary data (preview)")
                    continue
            except websocket.WebSocketTimeoutException:
                print("Websocket timed out waiting for a message")
                # Instead of just continuing, let's check if the image is ready
                try:
                    print("Checking if execution is complete via history endpoint")
                    history = get_history(prompt_id)
                    if prompt_id in history and 'outputs' in history[prompt_id]:
                        print("Found outputs in history, execution appears to be complete")
                        break
                    else:
                        print("No outputs found in history yet, continuing to wait")
                except Exception as e:
                    print(f"Error checking history: {str(e)}")
                    # Continue waiting
        
        print("Getting history for prompt")
        try:
            history = get_history(prompt_id)[prompt_id]
            print(f"Got history with {len(history['outputs'])} outputs")
            
            for node_id in history['outputs']:
                node_output = history['outputs'][node_id]
                images_output = []
                
                if 'images' in node_output:
                    print(f"Found {len(node_output['images'])} images in node {node_id}")
                    
                    for image in node_output['images']:
                        print(f"Getting image: {image['filename']}")
                        try:
                            image_data = get_image(image['filename'], image['subfolder'], image['type'])
                            print(f"Retrieved image data, size: {len(image_data)} bytes")
                            images_output.append(image_data)
                        except Exception as e:
                            print(f"Error getting image {image['filename']}: {str(e)}")
                
                output_images[node_id] = images_output
            
            print(f"Returning {sum(len(imgs) for imgs in output_images.values())} images in total")
            return output_images
        except Exception as e:
            print(f"Error processing history: {str(e)}")
            return {}
    except Exception as e:
        print(f"Unexpected error in get_images: {str(e)}")
        return {}

##
## Fonction copiée de:
## https://github.com/sbszcz/image-upload-comfyui-example/blob/main/run-workflow.py
## 
## Modifiée pour charger un masque aussi
def upload_file(file, subfolder="", overwrite=False, is_mask = False):
    try:
        body = {"image": file}
        data = {}
        
        if overwrite:
            data["overwrite"] = "true"
  
        if subfolder:
            data["subfolder"] = subfolder

        if is_mask:
            resp = requests.post(f"http://{server_address}/upload/mask", files=body,data=data)
        else:
            resp = requests.post(f"http://{server_address}/upload/image", files=body,data=data)
        
        if resp.status_code == 200:
            data = resp.json()
            path = data["name"]
            if "subfolder" in data:
                if data["subfolder"] != "":
                    path = data["subfolder"] + "/" + path
        else:
            print(f"{resp.status_code} - {resp.reason}")
    except Exception as error:
        print(error)
    return path

################################################################################

def read_workflow(filepath):
    with open(filepath, 'r') as f:
        return json.load(f)


if __name__ == '__main__':
    workflow = read_workflow('Workflows/seamless_textures.json')

    seed = 5
    # from random import randint
    # seed = randint()
    
    # set_positive_prompt(workflow, '16', 'big pizza the shape of a guitar, must be in once piece, masterpiece, best quality')
    # # set_negative_prompt(workflow, '7', 'ahah')
    # set_seed(workflow, '11', seed)
    # set_ckpt(workflow, '4', 'SDXL/sd_xl_base_1.0.safetensors')
    # ## SDXL model works best with 1024x1024 images or same number pixels
    # set_img_width(workflow, '5', 1014)
    # set_img_height(workflow, '5', 1014)
    # seamless_xaxis(workflow, '11', False)
    # seamless_yaxis(workflow, '11', False)
    
    ws = websocket.WebSocket()
    ws.connect("ws://{}/ws?clientId={}".format(server_address, client_id))
    images = get_images(ws, workflow)
    ws.close() # for in case this example is used in an environment where it will be repeatedly called, like in a Gradio app. otherwise, you'll randomly receive connection timeouts
    #Commented out code to display the output images:
    
    for node_id in images:
        for image_data in images[node_id]:
            from PIL import Image
            import io
            image = Image.open(io.BytesIO(image_data))
            image.show()
            # save the image
            image.save("output.png")
