import sys

import finalfusion
import numpy as np


def test(words, inp, output):
    print(words, inp, output)
    original = finalfusion.load_finalfusion(inp)
    selected = finalfusion.load_finalfusion(output)
    with open(words) as word_file:
        word_list = [word.strip() for word in word_file]
    assert word_list in selected.vocab
    assert len(selected.vocab) == len(word_list)
    for word in word_list:
        assert np.allclose(original[word], selected[word])


if __name__ == '__main__':
    test(*sys.argv[1:])
