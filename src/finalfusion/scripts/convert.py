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

from finalfusion.scripts.util import Format, add_input_output_args, add_format_args, add_common_args


def main() -> None:  # pylint: disable=missing-function-docstring
    formats = ["word2vec", "finalfusion", "fasttext", "text", "textdims"]
    parser = argparse.ArgumentParser(prog="ffp-convert",
                                     description="Convert embeddings.")
    add_input_output_args(parser)
    add_format_args(parser, "f", "from", formats, "word2vec")
    add_format_args(parser, "t", "to", formats, "finalfusion")
    add_common_args(parser)
    args = parser.parse_args()
    embeds = Format(getattr(args, 'from')).load(args.input, args.lossy,
                                                args.mmap)
    Format(args.to).write(args.output, embeds)


if __name__ == '__main__':
    main()
