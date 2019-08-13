TEST_NGRAM_INDICES = [
    ('tüb',
     14),
    ('en>',
     69),
    ('übinge',
     74),
    ('gen',
     124),
    ('ing',
     168),
    ('ngen',
     181),
    ('bing',
     197),
    ('inge',
     246),
    ('übin',
     250),
    ('tübi',
     276),
    ('bingen',
     300),
    ('<tübin',
     308),
    ('bin',
     325),
    ('übing',
     416),
    ('gen>',
     549),
    ('ngen>',
     590),
    ('ingen>',
     648),
    ('tübing',
     651),
    ('übi',
     707),
    ('ingen',
     717),
    ('binge',
     761),
    ('<tübi',
     817),
    ('<tü',
     820),
    ('<tüb',
     857),
    ('nge',
     860),
    ('tübin',
     1007)]


def test_embeddings_with_norms_oov(embeddings_fifu):
    vocab = embeddings_fifu.vocab()
    assert vocab.item_to_indices("Something out of vocabulary") is None


def test_ngram_indices(subword_fifu):
    vocab = subword_fifu.vocab()
    ngram_indices = sorted(vocab.ngram_indices("tübingen"), key=lambda tup: tup[1])
    for ngram_index, test_ngram_index in zip(
            ngram_indices, TEST_NGRAM_INDICES):
        assert ngram_index == test_ngram_index


def test_subword_indices(subword_fifu):
    vocab = subword_fifu.vocab()
    subword_indices = sorted(vocab.subword_indices("tübingen"))
    for subword_index, test_ngram_index in zip(
            subword_indices, TEST_NGRAM_INDICES):
        assert subword_index == test_ngram_index[1]
