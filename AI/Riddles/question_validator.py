from ollama import chat
from pydantic import BaseModel, Field
from typing import List

class LlmException(Exception):
    pass

class IsRightAnswer(BaseModel):
    is_right: bool = Field(default=False)

def check_if_right_answer(model, question, correct_answer, answer):
    
    with open("Prompts/question_validator.txt", "r") as f:
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

def check_answer(question, correct_answer, answer, model = "qwen2.5", nb_checks = 5):
    answers = []
    for _ in range(nb_checks):
        response = check_if_right_answer(model, question, correct_answer, answer)
        answers.append(response.is_right)
    # print(answers)

    # Return the majority vote
    return max(set(answers), key = answers.count)
    # return False if one of the answers is False
    # return False not in answers

if __name__ == '__main__':
    question = "He died for people's entertainment. "
    answer = "gladiator"
    user_answer = "warrior in Rome"

    try:
        response = check_answer(question, answer, user_answer)
        print(response)
    except LlmException as e:
        print(e)
