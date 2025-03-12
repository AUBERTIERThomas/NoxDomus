import AI.Images.comfyui_api as comfyui

from websocket import WebSocket
from uuid import uuid4
from random import randint
import os

# Constants
# TODO: define these constants in a config file
server_address = "127.0.0.1:8188"

# Helper functions to customize the prompt
# The node_id is the id of the node in the workflow json file (it depends)
class CustomizeWorkflow():
    """
    Class to customize the prompt of a node in the workflow

Args:
    - workflow_path: path to the workflow json file
    """
    def __init__(self, workflow_path):
        self.workflow = comfyui.read_workflow(workflow_path)

    def set_positive_prompt(self, node_id, text):
        self.workflow[node_id]['inputs']['text'] = text

    def set_negative_prompt(self, node_id, text):
        self.workflow[node_id]['inputs']['text'] = text

    def set_seed(self, node_id, seed):
        self.workflow[node_id]['inputs']['seed'] = seed

    def set_random_seed(self, node_id):
        seed = randint(0, 2**32 - 1)
        self.set_seed(node_id, seed)

    # Name of the checkpoint
    def set_ckpt(self, node_id, ckpt_name):
        self.workflow[node_id]['inputs']['ckpt_name'] = ckpt_name

    def set_img_width(self, node_id, width):
        self.workflow[node_id]['inputs']['width'] = width

    def set_img_height(self, node_id, height):
        self.workflow[node_id]['inputs']['height'] = height

    # Works with the Assymmetric Tiled KSampler if node exists in the workflow
    def seamless_xaxis(self, node_id, enable):
        a = 0
        if enable:
            a = 1
        self.workflow[node_id]['inputs']['tileX'] = a

    # Works with the Assymmetric Tiled KSampler if node exists in the workflow
    def seamless_yaxis(self, node_id, enable):
        a = 0
        if enable:
            a = 1
        self.workflow[node_id]['inputs']['tileY'] = a

    # Works with the Assymmetric Tiled KSampler if node exists in the workflow
    def seamless_both(self, node_id, enable):
        self.seamless_xaxis(node_id, enable)
        self.seamless_yaxis(node_id, enable)

class Comfyui(CustomizeWorkflow):
    """
    Class to run the workflow and get the images.

    Note: The images will be saved in the output folder of Comfy UI.
    If you want to save the images in a different folder, you can use the run_and_save method but it will also save the images in the output folder of Comfy UI.

    Args:
    - workflow_path: path to the workflow json file
    """
    def __init__(self, workflow_path):
        super().__init__(workflow_path) # load the workflow
        self.ws = WebSocket()
        self.client_id = str(uuid4())

    def __run(self):
        print("Connecting to the server")
        try:
            # Set a shorter timeout for the websocket connection
            # self.ws.settimeout(60)  # 60 seconds timeout
            self.ws.connect("ws://{}/ws?clientId={}".format(server_address, self.client_id))
            print("Connected to server, beginning image generation")
            
            try:
                images = comfyui.get_images(self.ws, self.workflow)
                print("Successfully retrieved images from ComfyUI")
                return images
            except Exception as e:
                print(f"Exception in get_images: {str(e)}")
                return {}
            finally:
                try:
                    print("Closing the connection")
                    self.ws.close()
                    print("Connection closed")
                except Exception as e:
                    print(f"Error closing websocket: {str(e)}")
        except Exception as e:
            print(f"Error connecting to websocket: {str(e)}")
            return {}

    def run_and_save(self, name, output_folder):
        """
        Run the workflow and save the images in the output folder.
        BEWARE: if an image with the same name already exists, it will be overwritten.
    
        Args:
            name: Base name for the saved image file
            output_folder: Directory where images will be saved
        
        Returns:
            List of saved image paths if successful, empty list if failed
        """
        print(f"Starting image generation to save as '{name}'")
        try:
            # Create the output folder if it does not exist
            if not os.path.exists(output_folder):
                os.makedirs(output_folder)
                print(f"Created output folder: {output_folder}")
        
            images = self.__run()
            print(f"Image generation complete. Got images: {bool(images)}")
        
            if not images:
                print("No images were generated")
                return []
        
            saved_paths = []
            image_count = 0
            for node_id in images:
                print(f"Processing node_id: {node_id}")
                for i, image_data in enumerate(images[node_id]):
                    image_count += 1
                    try:
                        from PIL import Image
                        import io
                        
                        # Create a unique filename if multiple images are generated
                        filename = name
                        if image_count > 1:
                            filename = f"{name}_{image_count}"
                        
                        save_path = f"{output_folder}/{filename}.png"
                        
                        # Load and save the image
                        print(f"Processing image data for {save_path}")
                        image = Image.open(io.BytesIO(image_data))
                        image.save(save_path)
                        
                        print(f"Successfully saved image to: {save_path}")
                        saved_paths.append(save_path)
                    except Exception as e:
                        print(f"Error saving image: {str(e)}")
            
            print(f"Saved {len(saved_paths)} images successfully")
            return saved_paths
        except Exception as e:
            print(f"Error in run_and_save: {str(e)}")
            return []

    # Not used in api but useful for testing
    # def run_and_display(self):
    #     print("running in function")
    #     images = self.__run()
    #     for node_id in images:
    #         print("node_id: ", node_id)
    #         for image_data in images[node_id]:
    #             print("image_data")
    #             from PIL import Image
    #             import io
    #             image = Image.open(io.BytesIO(image_data))
    #             image.show()
    #             print("showed")

    def run_and_display(self):
        """
        Run the workflow and return image data.
        Returns True if successful, False otherwise.
        """
        print("Starting image generation")
        try:
            images = self.__run()
            print(f"Image generation complete. Got images: {bool(images)}")

            if not images:
                print("No images were generated")
                return False

            image_count = 0
            for node_id in images:
                print(f"Processing node_id: {node_id}")
                for image_data in images[node_id]:
                    image_count += 1
                    print(f"Processing image {image_count} from node {node_id}")
                    try:
                        from PIL import Image
                        import io
                        # Just verify the image can be opened without displaying
                        image = Image.open(io.BytesIO(image_data))
                        print(f"Successfully processed image: {image.size}")
                        # Don't call image.show() as it might block
                        image.show()
                    except Exception as e:
                        print(f"Error processing image: {str(e)}")
                        return False

            print(f"Successfully processed {image_count} images")
            return True
        except Exception as e:
            print(f"Error in run_and_display: {str(e)}")
            return False    
                
    # Dangerous territory

    def delete_image(self, name):
        os.remove(name)

    def delete_dir(self, name):
        os.rmdir(name)
    
    def delete_images(self, output_folder):
        """
        Warning: no check is done to verify what is deleted. Could be the kernel,
        not my problem.
        """
        self.delete_dir(output_folder)


