# pylint: disable=missing-docstring
from argparse import ArgumentParser
from enum import Enum
from typing import List

from finalfusion import Embeddings, load_finalfusion
from finalfusion.compat import write_word2vec, write_text, write_text_dims, write_fasttext, \
    load_word2vec, load_text, load_text_dims, load_fasttext


def add_input_output_args(parser: ArgumentParser):
    parser.add_argument("input",
                        type=str,
                        help="Input embeddings",
                        metavar="INPUT")
    parser.add_argument("output",
                        type=str,
                        help="Output path",
                        metavar="OUTPUT")


def add_format_args(parser: ArgumentParser, short: str, name: str,
                    formats: List[str], default: str):
    parser.add_argument(f"-{short}",
                        f"--{name}",
                        type=str,
                        choices=formats,
                        default=default,
                        help=f"Valid choices: {formats} Default: '{default}'",
                        metavar="FORMAT")


def add_common_args(parser: ArgumentParser):
    parser.add_argument(
        "-l",
        "--lossy",
        action="store_true",
        default=False,
        help=
        "Whether to fail on malformed UTF-8. Setting this flag replaces malformed UTF-8 "
        "with the replacement character. Not applicable to finalfusion format."
    )
    parser.add_argument(
        "--mmap",
        action="store_true",
        default=False,
        help=
        "Whether to mmap the storage. Only applicable to finalfusion files.")


class Format(Enum):
    """
    Supported embedding formats.
    """
    finalfusion = "finalfusion"
    fasttext = "fasttext"
    word2vec = "word2vec"
    textdims = "textdims"
    text = "text"

    def write(self, path: str, embeddings: Embeddings):
        """
        Helper to write different Formats
        """
        if self == Format.finalfusion:
            embeddings.write(path)
        elif self == Format.word2vec:
            write_word2vec(path, embeddings)
        elif self == Format.text:
            write_text(path, embeddings)
        elif self == Format.textdims:
            write_text_dims(path, embeddings)
        elif self == Format.fasttext:
            write_fasttext(path, embeddings)
        else:
            raise ValueError(f"Unknown format {str(self)}")

    def load(self, path: str, lossy: bool, mmap: bool) -> Embeddings:
        """
        Helper to load different Formats
        """
        if self == Format.finalfusion:
            return load_finalfusion(path, mmap)
        if self == Format.word2vec:
            return load_word2vec(path, lossy)
        if self == Format.text:
            return load_text(path, lossy)
        if self == Format.textdims:
            return load_text_dims(path, lossy)
        if self == Format.fasttext:
            return load_fasttext(path, lossy)
        raise ValueError(f"Unknown format {str(self)}")
