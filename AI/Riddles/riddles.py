from .creation.create_riddles import Riddles, read_from_csv
from random import choice

class RiddlesHandler:
    def __init__(self, filepath):
        self.riddles = read_from_csv(filepath)
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

