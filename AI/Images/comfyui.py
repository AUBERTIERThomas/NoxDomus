import json
from urllib import request
from random import randint

def read_workflow(filepath):
    with open(filepath, 'r') as f:
        return json.load(f)

def queue_prompt(prompt):
    p = {"prompt": prompt}
    data = json.dumps(p).encode('utf-8')
    req =  request.Request("http://127.0.0.1:8188/prompt", data=data)
    request.urlopen(req)

if __name__ == '__main__':
    workflow = read_workflow('workflow.json')
    workflow['6']['inputs']['text'] = "A big burger with fries"
    workflow['4']['inputs']['ckpt_name'] = "v1-5-pruned-emaonly-fp16.safetensors"
    workflow['3']['inputs']['seed'] = randint(0, 2**32 - 1)
    # print(workflow)

    queue_prompt(workflow)
