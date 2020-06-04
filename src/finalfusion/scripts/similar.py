"""
Similarity queries for embeddings.
"""
import argparse
import sys

from finalfusion.scripts.util import Format


def main() -> None:  # pylint: disable=missing-function-docstring
    formats = ["word2vec", "finalfusion", "fasttext", "text", "textdims"]
    parser = argparse.ArgumentParser(prog="ffp-similar",
                                     description="Similarity queries.")
    parser.add_argument("embeddings",
                        type=str,
                        help="Input embeddings",
                        metavar="EMBEDDINGS")
    parser.add_argument(
        "-f",
        "--format",
        type=str,
        choices=formats,
        default="finalfusion",
        help=f"Valid choices: {formats} Default: 'finalfusion'",
        metavar="INPUT_FORMAT")
    parser.add_argument("-k",
                        type=int,
                        help="Number of neighbours. Default: 10",
                        default=10,
                        metavar="K")
    parser.add_argument(
        "input",
        help=
        "Optional input file with one word per line. If unspecified reads from stdin",
        nargs='?',
        default=0,
    )
    args = parser.parse_args()
    embeds = Format(args.format).load(args.embeddings)
    with open(args.input) as queries:
        for query in queries:
            query = query.strip()
            if not query:
                continue
            res = embeds.word_similarity(query, k=args.k)
            if res is None:
                print(f"Could not compute neighbours for: {query}",
                      file=sys.stderr)
            else:
                print("\n".join(f"{ws.word} {ws.similarity}" for ws in res))


if __name__ == '__main__':
    main()
