from ollama import chat
from pydantic import BaseModel, Field
from typing import List

class LlmException(Exception):
    pass

class IsRightAnswer(BaseModel):
    is_right: bool = Field(default=False)

def check_if_right_answer(model, question, correct_answer, answer):
    system_prompt = """
    You are a teacher grading a student's answer to a question.
    You have the student's answer and the correct answer. You need to determine if the student's answer is correct and give a grade.
    Answer the question: Is the student's answer correct? (True or False)

    You will be provided with the question, the student's answer, and the correct answer.

    You will output a JSON object with a key, "is_right", that has a boolean value (True or False).    
    Example input:
    {
        "question":  "What does no man want, yet no man want to lose?",
        "correct_answer": "job",
        "student_answer": "work",
    }
    
    Example output:
    {
        "is_right": True,
    }

    Only answer as valid JSON format.

    Only accept the answer if it is right. If it is a synonym, it is still right.
    If it contains a typo, it is still right. If it is a different form of the word, it is still right. If it is a different tense, it is still right.
    If it is a different plural form, it is still right. If it is a different singular form, it is still right. 
    If the anwer contains the correct answer, it is still right.
    Otherwise, it is always wrong.
    """

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

def check_answer(question, correct_answer, answer):
    model = "qwen2.5"
    answers = []
    for _ in range(5):
        response = check_if_right_answer(model, question, correct_answer, answer)
        answers.append(response.is_right)
    print(answers)
    # Return the majority vote
    return max(set(answers), key = answers.count)

    # return False if one of the answers is False
    # return False not in answers

if __name__ == '__main__':
    model = "llama3.1"
    question = "He died for people's entertainment. "
    answer = "gladiator"
    user_answer = "warrior in Rome"

    try:
        response = check_answer(question, answer, user_answer)
        print(response)
    except LlmException as e:
        print(e)
