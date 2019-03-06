#!/usr/bin/env python3

import sys

from finalfusion import Embeddings

if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.stderr.write("Usage: %s embeddings\n" % sys.argv[0])
        sys.exit(1)

    embeds = Embeddings(sys.argv[1])

    for line in sys.stdin:
        print(" ".join(map(lambda v: str(v), embeds.embedding(line.strip()))))
