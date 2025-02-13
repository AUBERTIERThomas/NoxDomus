from pydantic import BaseModel, RootModel, Field
from typing import List
import csv

class Riddle(BaseModel):
    question: str = Field(default="")
    answer: str = Field(default="")

class Riddles(RootModel):
    """
    Riddles class to store a list of riddles.
    
    Standard format to pass to other functions, which require a list of riddles.
    """
    root: List[Riddle] = Field(default=[])

# Has to be format question,answer (because of the riddles.csv file)
def read_from_csv(filepath, header=True, delimiter=','):
    """
    Read riddles from a csv file and return a list of riddles.
    Input: file has to be in the format question,answer

    Format output:
    [
        {
            "question": "What has keys but can't open locks?",
            "answer": "A piano"
        },
        {
            "question": "What has a head, a tail, is brown, and has no legs?",
            "answer": "A penny"
        },
        ...
    ]
    """

    with open(filepath, 'r') as f:
        csv_reader = csv.reader(f, delimiter=delimiter)

        riddles = Riddles()

        # Skip the header
        if header:
            next(csv_reader)

        for row in csv_reader:
            riddle = Riddle(question=row[0], answer=row[1])
            riddles.root.append(riddle)

        print("total number of riddles: ", csv_reader.line_num)

    # First 5 Riddles
    # print(riddles.root[:5])
    return riddles

if __name__ == '__main__':
    riddles = read_from_csv('riddles.csv')
    print(riddles)
