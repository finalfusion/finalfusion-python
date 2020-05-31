"""
Conversion for Word Embeddings.

Offers conversion from and to any combination of:
    * finalfusion
    * fastText
    * word2vec
    * textdims
    * text

Conversion of finalfusion files with FinalfusionBucketVocab or ExplicitVocab to fastText
fails.
"""
import argparse

from finalfusion.scripts.util import Format


def main() -> None:  # pylint: disable=missing-function-docstring
    formats = ["word2vec", "finalfusion", "fasttext", "text", "textdims"]
    parser = argparse.ArgumentParser(prog="ffp-convert",
                                     description="Convert embeddings.")
    parser.add_argument("input",
                        type=str,
                        help="Input embeddings",
                        metavar="INPUT")
    parser.add_argument("output",
                        type=str,
                        help="Output path",
                        metavar="OUTPUT")
    parser.add_argument("-f",
                        "--from",
                        type=str,
                        choices=formats,
                        default="word2vec",
                        help=f"Valid choices: {formats} Default: 'word2vec'",
                        metavar="INPUT_FORMAT")
    parser.add_argument(
        "-t",
        "--to",
        type=str,
        choices=formats,
        default="finalfusion",
        help=f"Valid choices: {formats} Default: 'finalfusion'",
        metavar="OUTPUT_FORMAT")
    args = parser.parse_args()
    embeds = Format(getattr(args, 'from')).load(args.input)
    Format(args.to).write(args.output, embeds)


if __name__ == '__main__':
    main()
