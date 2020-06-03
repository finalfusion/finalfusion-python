"""
Conversion from bucket embeddings to explicit.
"""
import argparse

from finalfusion.scripts.util import Format


def main() -> None:  # pylint: disable=missing-function-docstring
    parser = argparse.ArgumentParser(
        prog="ffp-bucket-to-explicit",
        description="Convert bucket embeddings to explicit lookups.")
    parser.add_argument("input",
                        help="Input bucket embeddings",
                        type=str,
                        metavar="INPUT")
    parser.add_argument("output",
                        help="Output path",
                        type=str,
                        metavar="OUTPUT")
    parser.add_argument(
        "-f",
        "--from",
        type=str,
        choices=['finalfusion', 'fasttext'],
        default="finalfusion",
        help=
        "Valid choices: ['finalfusion', 'fasttext'] Default: 'finalfusion'",
        metavar="INPUT_FORMAT")
    args = parser.parse_args()
    embeds = Format(getattr(args, 'from')).load(args.input)
    embeds.bucket_to_explicit().write(args.output)


if __name__ == '__main__':
    main()
