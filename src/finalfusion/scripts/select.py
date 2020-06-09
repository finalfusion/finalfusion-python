"""
Write new embeddings according to a list of words.
"""
import argparse
import sys

import numpy as np
from finalfusion import Metadata, Embeddings
from finalfusion.scripts.util import Format, add_input_output_args, add_format_args, add_common_args
from finalfusion.storage import NdArray
from finalfusion.vocab import SimpleVocab


def main() -> None:  # pylint: disable=missing-function-docstring
    formats = ["word2vec", "finalfusion", "fasttext", "text", "textdims"]
    parser = argparse.ArgumentParser(
        prog="ffp-select", description="Build embeddings from list of words.")
    add_input_output_args(parser)
    add_format_args(parser, "f", "format", formats, "finalfusion")
    parser.add_argument(
        "words",
        nargs='?',
        default=0,
        metavar="WORDS",
        help=
        "List of words to include in the embeddings. One word per line. Spaces permitted."
        "Reads from stdin if unspecified.")
    parser.add_argument("--ignore_unk",
                        "-i",
                        action="store_true",
                        default=False,
                        help="Skip unrepresentable words.")
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        default=False,
        help=
        "Print which tokens are skipped because they can't be represented to stderr."
    )
    add_common_args(parser)
    args = parser.parse_args()
    embeds = Format(args.format).load(args.input, args.lossy, args.mmap)
    with open(args.words, errors='replace' if args.lossy else 'strict') as inp:
        unique_words = set(word.strip() for word in inp)
        matrix = np.zeros((len(unique_words), embeds.storage.shape[1]),
                          dtype=np.float32)
        vocab = SimpleVocab(list(unique_words))
        for i, word in enumerate(vocab):
            try:
                matrix[i] = embeds[word]
            except KeyError:
                if args.verbose or not args.ignore_unk:
                    print(f"Cannot represent '{word}'.", file=sys.stderr)
                if not args.ignore_unk:
                    sys.exit(1)
    metadata = Metadata({"source_embeddings": args.input})
    if embeds.metadata is not None:
        metadata["source_metadata"] = embeds.metadata
    Embeddings(storage=NdArray(matrix), vocab=vocab,
               metadata=metadata).write(args.output)


if __name__ == '__main__':
    main()
