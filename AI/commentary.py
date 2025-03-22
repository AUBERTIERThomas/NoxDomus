from ollama import chat
from pydantic import BaseModel, Field
from typing import List

class LlmException(Exception):
    pass

class Response(BaseModel):
    """
    Response from the llm model.
    Used to validate the json response.
    """
    response: str = Field(default="")

class Commentary(BaseModel):
    """
    Commentary from the llm model.
    Basically the same as `Response` but with stats.
    """
    response: str = Field(default="")
    total_duration: int | None = Field(default=0)
    load_duration: int | None = Field(default=0)
    prompt_eval_count: int | None = Field(default=0)
    eval_count: int | None = Field(default=0)
    eval_duration: int | None = Field(default=0)
    created_at: str | None = Field(default="")
    model: str | None = Field(default="")

def comment(is_user_right, question, correct_answer, user_answer, model = "qwen2.5"):
    """
    Get a commentary on game action from the llm model using the prompt in `Prompts/commentary.txt`.
    """
    with open("Prompts/commentary.txt", "r") as f:
        system_prompt = f.read()
    # print(system_prompt)

    prompt = f"""
    {{
        "question": "{question}",
        "correct_answer": "{correct_answer}",
        "student_answer": "{user_answer}" ## C'est écrit student car voir prompt systeme utilisé
        "is_user_right": {is_user_right}
    }}
    """

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

    comment = Response.model_validate_json(response.message.content)
    
    comment_stats = Commentary()
    comment_stats.response = comment.response
    comment_stats.total_duration = response.total_duration
    comment_stats.load_duration = response.load_duration
    comment_stats.prompt_eval_count = response.prompt_eval_count
    comment_stats.eval_count = response.eval_count
    comment_stats.eval_duration = response.eval_duration
    comment_stats.created_at = response.created_at
    comment_stats.model = response.model

    return comment_stats

if __name__ == '__main__':
    model = "phi3.5"
    question = "He died for people's entertainment. "
    answer = "gladiator"
    user_answer = "soldier"
    is_user_right = False

    try:
        response = comment(is_user_right, question, answer, user_answer, model)

        response.model
        
        print(response.response)
        print(response.total_duration)
        print(response.load_duration)
        print(response.prompt_eval_count)
        print(response.eval_count)
        print(response.eval_duration)
        print(response.created_at)
        print(response.model)

    except LlmException as e:
        print(e)
