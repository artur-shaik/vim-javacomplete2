from .base import Base

class Source(Base):
    def __init__(self, vim):
        Base.__init__(self, vim)

        self.name = 'javacomplete2'
        self.mark = '[jc]'
        self.filetypes = ['java', 'jsp']
        self.is_bytepos = True
        self.min_pattern_length = 0

    def get_complete_position(self, context):
        return self.vim.call('javacomplete#Complete', 1, 0)

    def gather_candidates(self, context):
        return self.vim.call('javacomplete#Complete', 0, context['complete_str'])
