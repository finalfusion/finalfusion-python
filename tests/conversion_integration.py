import sys

import numpy as np

from finalfusion.scripts.util import Format
from finalfusion.vocab.subword import FastTextVocab, SubwordVocab


def test(inp, input_format, output, output_format):
    e1 = Format(input_format).load(inp)
    e2 = Format(output_format).load(output)
    if isinstance(e1.vocab, FastTextVocab) and \
            output_format in ["finalfusion", "fasttext"]:
        exit(cmp_subword_embeds(e1, e2))

    if isinstance(e1.vocab, SubwordVocab) and \
            input_format in ["fasttext", "finalfusion"] and \
            output_format in ["word2vec", "text", "textdims"]:
        exit(cmp_subword_embeds_to_simple(e1, e2))

    if input_format in ["finalfusion", "word2vec", "text", "textdims"]:
        exit(cmp_simple_embeds(e1, e2))
    print(
        f"missing testcase for {input_format} to {output_format} ({inp} to {output})",
        file=sys.stderr)
    exit(1)


def cmp_simple_embeds(e1, e2):
    assert e1.vocab == e2.vocab
    assert np.allclose(e1.storage, e2.storage, atol=1e-5)
    assert np.allclose(e1.norms, e2.norms, atol=1e-5)
    return 0


def cmp_subword_embeds_to_simple(e1, e2):
    assert e1.vocab.words == e2.vocab.words
    assert e1.vocab.word_index == e2.vocab.word_index
    assert np.allclose(e1.storage[:len(e1.vocab)], e2.storage, atol=1e-5)
    if e1.norms is not None:
        assert np.allclose(e1.norms, e2.norms, atol=1e-5)
    return 0


def cmp_subword_embeds(e1, e2):
    assert e1.vocab == e2.vocab
    assert np.allclose(e1.storage, e2.storage, atol=1e-5)
    if e1.norms is not None:
        assert np.allclose(e1.norms, e2.norms, atol=1e-5)
    return 0


if __name__ == '__main__':
    test(*sys.argv[1:])
