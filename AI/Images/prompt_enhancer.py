from ollama import chat
from pydantic import BaseModel, Field

class LlmException(Exception):
    pass

class Response(BaseModel):
    """
    Response from the llm model.
    Used to validate the json response.
    """
    enhanced_prompt: str = Field(default="")

def enhance_prompt(prompt, model = "phi3.5"):
    """
    Enhance a prompt with the llm model using the prompt in `Prompts/prompt_enhancer.txt`.
    """
    with open("AI/Prompts/prompt_enhancer.txt", "r") as f:
        system_prompt = f.read()
    # print(system_prompt)

    response = chat(
        model=model,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt},
        ],
        format = Response.model_json_schema(),
    )
    # print(response)

    if response.message.content == None:
        raise LlmException("No response from the model")

    enhanced_prompt = Response.model_validate_json(response.message.content)
    return enhanced_prompt

if __name__ == "__main__":
    prompt = "spiders"
    enhanced_prompt = enhance_prompt(prompt)
    print(enhanced_prompt)
    print(type(enhanced_prompt))
