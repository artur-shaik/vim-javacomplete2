from .base import Base

class Source(Base):
    def __init__(self, vim):
        Base.__init__(self, vim)

        self.name = 'javacomplete2'
        self.mark = '[jc]'
        self.filetypes = ['java', 'jsp']
        self.is_bytepos = True
        self.input_pattern = '[^. \t0-9]\.\w*'

    def get_complete_position(self, context):
        return self.vim.call('javacomplete#complete#complete#Complete', 1, '')

    def gather_candidates(self, context):
        return self.vim.call('javacomplete#complete#complete#Complete', 0, '')
