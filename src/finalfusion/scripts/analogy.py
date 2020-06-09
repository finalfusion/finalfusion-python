"""
Analogy queries for embeddings.
"""
import argparse
import sys
from typing import List, Set

from finalfusion.scripts.util import Format, add_format_args, add_common_args


def main() -> None:  # pylint: disable=missing-function-docstring
    formats = ["word2vec", "finalfusion", "fasttext", "text", "textdims"]
    parser = argparse.ArgumentParser(prog="ffp-analogy",
                                     description="Analogy queries.")
    parser.add_argument("embeddings",
                        help="Input embeddings",
                        type=str,
                        metavar="EMBEDDINGS")
    add_format_args(parser, "f", "format", formats, "finalfusion")
    parser.add_argument(
        "-i",
        "--include",
        choices=["a", "b", "c"],
        nargs="+",
        default=[],
        help=
        "Specify query parts that should be allowed as answers. Valid choices: ['a', 'b', 'c']"
    )
    parser.add_argument("-k",
                        type=int,
                        default=10,
                        help="Number of neighbours. Default: 10",
                        metavar="K")
    parser.add_argument(
        "input",
        help=
        "Optional input file with 3 words per line. If unspecified reads from stdin",
        nargs='?',
        default=0)
    add_common_args(parser)
    args = parser.parse_args()
    if args.include != [] and len(args.include) > 3:
        print("-i/--include can take up to 3 unique values: a, b and c.",
              file=sys.stderr)
        sys.exit(1)
    embeds = Format(args.format).load(args.embeddings, args.lossy, args.mmap)
    with open(args.input) as queries:
        for query in queries:
            query_a, query_b, query_c = query.strip().split()
            skips = get_skips(query_a, query_b, query_c, args.include)
            res = embeds.analogy(query_a,
                                 query_b,
                                 query_c,
                                 k=args.k,
                                 skip=skips)
            if res is None:
                print(
                    f"Could not compute for: {query_a} : {query_b}, {query_c} : ? ",
                    file=sys.stderr)
            else:
                print("\n".join(f"{ws.word} {ws.similarity}" for ws in res))


def get_skips(  # pylint: disable=missing-function-docstring
        query_a: str, query_b: str, query_c: str,
        includes: List[str]) -> Set[str]:
    if includes == []:
        return {query_c, query_b, query_a}
    skips = set()
    if 'a' not in includes:
        skips.add(query_a)
    if 'b' not in includes:
        skips.add(query_b)
    if 'c' not in includes:
        skips.add(query_b)
    return skips


if __name__ == '__main__':
    main()
