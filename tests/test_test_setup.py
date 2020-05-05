import numpy as np


def test_vocab_array_tuple_fixture(vocab_array_tuple):
    v, m = vocab_array_tuple
    assert v == ["one", "two", "three", "four", "five", "six", "seven"]
    target_list = [[3.0, 1.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 4.0, 3.0],
                   [2.0, 3.0, 3.0, 3.0, 3.0, 2.0, 0.0, 3.0, 3.0, 4.0],
                   [0.0, 0.0, 2.0, 0.0, 2.0, 1.0, 2.0, 4.0, 0.0, 3.0],
                   [1.0, 4.0, 4.0, 2.0, 4.0, 2.0, 4.0, 1.0, 3.0, 1.0],
                   [0.0, 4.0, 1.0, 2.0, 0.0, 4.0, 0.0, 3.0, 1.0, 3.0],
                   [3.0, 3.0, 4.0, 2.0, 0.0, 0.0, 0.0, 3.0, 2.0, 1.0],
                   [1.0, 4.0, 0.0, 2.0, 2.0, 2.0, 4.0, 3.0, 1.0, 1.0]]
    target = np.array(target_list, dtype=np.float32)
    assert np.allclose(m, target)
