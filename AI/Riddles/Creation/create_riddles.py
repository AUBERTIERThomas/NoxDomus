from pydantic import BaseModel, RootModel, Field
from typing import List
import csv
import json

class Riddle(BaseModel):
    question: str = Field(default="")
    answer: str = Field(default="")

class Riddles(RootModel):
    """
    Riddles class to store a list of riddles.
    
    Standard format to pass to other functions, which require a list of riddles.
    It is the format output of the read_from_csv and read_from_json functions.
    """
    root: List[Riddle] = Field(default=[])

    # ovveride + and += operator to concatenate two Riddles objects
    def __add__(self, other):
        return Riddles(root=self.root + other.root)

    def __iadd__(self, other):
        self.root += other.root
        return self

# riddles.csv file
def read_from_csv(filepath, header=True, delimiter=','):
    with open(filepath, 'r', encoding = "utf8") as f:
        csv_reader = csv.reader(f, delimiter=delimiter)

        riddles = Riddles()

        # Skip the header
        if header:
            next(csv_reader)

        for row in csv_reader:
            riddle = Riddle(question=row[0], answer=row[1])
            riddles.root.append(riddle)

    return riddles

def read_from_csv2(filepath, header=True, delimiter=','):
    with open(filepath, 'r', encoding = "utf8") as f:
        csv_reader = csv.reader(f, delimiter=delimiter)

        riddles = Riddles()

        # Skip the header
        if header:
            next(csv_reader)

        for row in csv_reader:
            riddle = Riddle(question=row[0], answer=row[1])
            riddles.root.append(riddle)

    return riddles


# ridddles.json file
def read_from_json(filepath):
    with open(filepath, 'r', encoding = "utf8") as f:
        data = json.load(f)

        riddles = Riddles()

        for riddle in data:
            riddle = Riddle(question=riddle['riddle'], answer=riddle['answer'])
            riddles.root.append(riddle)

    return riddles


if __name__ == '__main__':
    riddles1 = read_from_csv2('Riddles.csv')
    riddles2 = read_from_json('riddles.json')
    riddles3 = read_from_csv('riddles.csv')
    riddles4 = read_from_json('riddles2.json')
    

    print(len(riddles1.root))
    print(len(riddles2.root))
    print(len(riddles3.root))
    print(len(riddles4.root))
