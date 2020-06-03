"""
Finalfusion embeddings in Python
"""

from finalfusion.compat import load_fasttext, load_text, load_text_dims, load_word2vec
from finalfusion.embeddings import Embeddings, load_finalfusion
from finalfusion.metadata import Metadata, load_metadata
from finalfusion.storage import Storage, load_storage
from finalfusion.vocab import Vocab, load_vocab

__all__ = [
    'load_fasttext', 'load_text', 'load_text_dims', 'load_word2vec',
    'Embeddings', 'load_finalfusion', 'Metadata', 'load_metadata', 'Storage',
    'load_storage', 'Vocab', 'load_vocab'
]
