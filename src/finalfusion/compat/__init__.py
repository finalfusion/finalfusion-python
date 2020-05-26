"""
Compatibility Module for Embedding formats

This module contains read and write methods for other common embedding formats such as:
    * text(-dims)
    * word2vec binary
    * fastText
"""
from finalfusion.compat.fasttext import write_fasttext, load_fasttext
from finalfusion.compat.text import load_text, load_text_dims, write_text, write_text_dims
from finalfusion.compat.word2vec import load_word2vec, write_word2vec

__all__ = [
    'load_text_dims', 'load_word2vec', 'load_text', 'write_word2vec',
    'write_text', 'write_text_dims', 'load_fasttext', 'write_fasttext'
]
