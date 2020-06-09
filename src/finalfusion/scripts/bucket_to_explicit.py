"""
Conversion from bucket embeddings to explicit.
"""
import argparse

from finalfusion.scripts.util import Format, add_input_output_args, add_format_args, add_common_args


def main() -> None:  # pylint: disable=missing-function-docstring
    parser = argparse.ArgumentParser(
        prog="ffp-bucket-to-explicit",
        description="Convert bucket embeddings to explicit lookups.")

    add_input_output_args(parser)
    add_format_args(parser, "f", "from", ["finalfusion", "fasttext"],
                    "finalfusion")
    add_common_args(parser)
    args = parser.parse_args()
    embeds = Format(getattr(args, 'from')).load(args.input, args.lossy,
                                                args.mmap)
    embeds.bucket_to_explicit().write(args.output)


if __name__ == '__main__':
    main()
