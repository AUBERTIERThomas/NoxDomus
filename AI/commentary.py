from ollama import chat
from pydantic import BaseModel, Field
from typing import List

class LlmException(Exception):
    pass

class Commentary(BaseModel):
    reponse_ia: str = Field(default="")

def comment(is_user_right, question, correct_answer, student_answer, model = "qwen2.5"):

    with open("Prompts/commentary.txt", "r") as f:
        system_prompt = f.read()
    # print(system_prompt)

    prompt = f"""
    {{
        "question": "{question}",
        "correct_answer": "{correct_answer}",
        "student_answer": "{student_answer}"
        "is_user_right": {is_user_right}
    }}
    """

    response = chat(
        model=model,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt},
        ],
        format = Commentary.model_json_schema(),
    )
    if response.message.content == None:
        raise LlmException("No response from the model")
    return Commentary.model_validate_json(response.message.content)

if __name__ == '__main__':
    model = "phi3.5"
    question = "He died for people's entertainment. "
    answer = "gladiator"
    user_answer = "soldier"
    is_user_right = False

    try:
        response = comment(is_user_right, question, answer, user_answer, model)
        print(response)
    except LlmException as e:
        print(e)
