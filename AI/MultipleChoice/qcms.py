from .create_qcm import read_qcm
from random import choice

class QcmHandler:
    def __init__(self):
        self.qcms = read_qcm('AI/MultipleChoice/GeneralKnowledge.json')
        self.qcms += read_qcm('AI/MultipleChoice/Mythology.json')
        self.qcms += read_qcm('AI/MultipleChoice/Mathematics.json')
        #self.qcms += read_qcm('AI/MultipleChoice/manga.json')
        self.qcms += read_qcm('AI/MultipleChoice/History.json')
        self.qcms += read_qcm('AI/MultipleChoice/Geography.json')
        self.qcms_pool = self.qcms.root.copy()

    def reset_qcm_generator(self):
        self.qcms_pool = self.qcms.root.copy()

    def generate_random_qcm(self, authorize_repetition=False):
        if authorize_repetition:
            return choice(self.qcms.root)
        else:
            if len(self.qcms_pool) == 0:
                self.reset_qcm_generator()
            qcm = choice(self.qcms_pool)
            self.qcms_pool.remove(qcm)
            return qcm

    def get_number_of_qcms(self):
        return len(self.qcms.root)
