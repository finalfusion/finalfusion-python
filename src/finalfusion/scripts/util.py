# pylint: disable=missing-docstring
from enum import Enum
from functools import partial
from os import PathLike
from typing import Union, Callable

from finalfusion import Embeddings, load_finalfusion
from finalfusion.compat import write_word2vec, write_text, write_text_dims, write_fasttext, \
    load_word2vec, load_text, load_text_dims, load_fasttext


class Format(Enum):
    """
    Supported embedding formats.
    """
    finalfusion = "finalfusion"
    fasttext = "fasttext"
    word2vec = "word2vec"
    textdims = "textdims"
    text = "text"

    @property
    def write(
            self
    ) -> Callable[[Union[str, bytes, int, PathLike], Embeddings], None]:
        """
        Helper to get the write method for different Formats
        """
        if self == Format.finalfusion:

            def write_fifu(path: Union[str, bytes, int, PathLike],
                           embeddings: Embeddings):
                embeddings.write(path)

            return write_fifu
        if self == Format.word2vec:
            return write_word2vec
        if self == Format.text:
            return write_text
        if self == Format.textdims:
            return write_text_dims
        if self == Format.fasttext:
            return write_fasttext
        raise ValueError(f"Unknown format {str(self)}")

    @property
    def load(self) -> Callable[[Union[str, bytes, int, PathLike]], Embeddings]:
        """
        Helper to get the load method for different Formats
        """
        if self == Format.finalfusion:
            return partial(load_finalfusion, mmap=True)
        if self == Format.word2vec:
            return load_word2vec
        if self == Format.text:
            return load_text
        if self == Format.textdims:
            return load_text_dims
        if self == Format.fasttext:
            return load_fasttext
        raise ValueError(f"Unknown format {str(self)}")
