from ollama import chat
from pydantic import BaseModel, Field

from .Creation.create_riddles import Riddles, read_from_csv

class LlmException(Exception):
    pass

# Output json schema for the model response
class IsRightAnswer(BaseModel):
    """
    Used to validate the json response of the llm.
    """
    is_right: bool = Field(default=False)

def check_if_right_answer(question, correct_answer, answer, model):
    """
    Check if the answer is correct using the llm model using the prompt in `Prompts/question_validator.txt`.
    """
    with open("AI/Prompts/question_validator.txt", "r") as f:
        system_prompt = f.read()
    # print(system_prompt)

    prompt = f"""
    {{
        "question": "{question}",
        "correct_answer": "{correct_answer}",
        "student_answer": "{answer}"
    }}
    """

    response = chat(
        model=model,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt},
        ],
        format=IsRightAnswer.model_json_schema(),
    )

    if response.message.content == None:
        raise LlmException("No response from the model")
    return IsRightAnswer.model_validate_json(response.message.content)

def check_answer(question, correct_answer, answer, model, nb_checks = 5):
    """
    Check if the answer is correct using the llm model using the prompt in `Prompts/question_validator.txt`.

    Return the majority vote of the `nb_checks` checks. Calls `check_if_right_answer` function.
    """
    answers = []
    for _ in range(nb_checks):
        response = check_if_right_answer(question, correct_answer, answer, model)
        answers.append(response.is_right)
    print(answers)

    # Return the majority vote
    return max(set(answers), key = answers.count)

if __name__ == '__main__':
    # model = "qwen2.5"
    model = "phi3.5"
    question = "He died for people's entertainment. "
    answer = "gladiator"
    user_answer = "A woman with a sword and shield who fights"
    nb_checks = 1

    check = check_answer(question, answer, user_answer, model, nb_checks)
    print(check)
