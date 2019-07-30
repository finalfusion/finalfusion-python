import finalfusion

NGRAMS_INDICES_ORDER = [
    ("Dan", 214157),
    ("iël", 233912),
    ("Danië", 311961),
    ("iël>", 488897),
    ("niël>", 620206),
    ("anië", 741276),
    ("Dani", 841219),
    ("Daniël", 1167494),
    ("ani", 1192256),
    ("niël", 1489905),
    ("ël>", 1532271),
    ("nië", 1644730),
    ("<Dan", 1666166),
    ("aniël", 1679745),
    ("<Danië", 1680294),
    ("aniël>", 1693100),
    ("<Da", 2026735),
    ("<Dani", 2065822)
]

INDICES_ORDER = [75867, 104120, 136555, 456131, 599360, 722393, 938007,
                 985859, 1006102, 1163391, 1218704, 1321513, 1505861,
                 1892376]


def test_ngrams_indices():
    ngrams_indices = sorted(
        finalfusion.SuwbwordInfo("<Daniël>").get_ngrams_indices(
            3, 6, 21), key=lambda x: x[1])
    for (
            ngram_test, index_test), (ngram, index) in zip(
            ngrams_indices, NGRAMS_INDICES_ORDER):
        assert ngram_test == ngram
        assert index_test == index


def test_subword_indices():
    subword_indices = sorted(
        finalfusion.SuwbwordInfo("<hallo>").get_subword_indices(
            3, 6, 21))
    for index_test, index in zip(subword_indices, INDICES_ORDER):
        assert index_test == index
