from pydantic import BaseModel, RootModel, Field
from typing import List
import json

class Qcm(BaseModel):
    """
    Qcm class to store a multiple choice question.
    """
    question: str = Field(default="")
    correct_answer: str = Field(default="")
    incorrect_answers: List[str] = Field(default=[])
    category: str = Field(default="")

class Qcms(RootModel):
    """
    Qcms class to store a list of Qcms.
    """
    root: List[Qcm] = Field(default=[])

    # ovveride + and += operator to concatenate two Qcms objects
    def __add__(self, other):
        return Qcms(root=self.root + other.root)

    def __iadd__(self, other):
        self.root += other.root
        return self

def read_qcm(filepath):
    """
    Utility function to read a Qcm object from a json file in a specific format.
    """
    with open(filepath, 'r', encoding = "utf8") as f:
        data = json.load(f)
        
        qcms = Qcms()

        for qcm in data["results"]:
            qcms.root.append(Qcm(**qcm))

    return qcms

if __name__ == "__main__":
    qcms = read_qcm("GeneralKnowledge.json")
    print(qcms.model_dump_json(indent=2))
