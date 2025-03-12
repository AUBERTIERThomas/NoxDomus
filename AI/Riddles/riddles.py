from .Creation.create_riddles import read_from_csv, read_from_json, read_from_csv2
from random import choice

class RiddlesHandler:
    def __init__(self):
        self.riddles = read_from_csv('AI/Riddles/Creation/riddles.csv')
        self.riddles += read_from_json('AI/Riddles/Creation/riddles.json')
        self.riddles += read_from_json('AI/Riddles/Creation/riddles2.json')
        self.riddles += read_from_csv2('AI/Riddles/Creation/Riddles.csv')
        self.riddles_pool = self.riddles.root.copy()

    def reset_riddle_generator(self):
        self.riddles_pool = self.riddles.root.copy()

    def generate_random_riddle(self, authorize_repetition=False):
        if authorize_repetition:
            return choice(self.riddles.root)
        else:
            if len(self.riddles_pool) == 0:
                self.reset_riddle_generator()
            riddle = choice(self.riddles_pool)
            self.riddles_pool.remove(riddle)
            return riddle

    def get_number_of_riddles(self):
        return len(self.riddles.root)

