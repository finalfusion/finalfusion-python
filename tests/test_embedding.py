import pytest
import numpy

TEST_NORMS = [
    6.557438373565674,
    8.83176040649414,
    6.164413928985596,
    9.165151596069336,
    7.4833149909973145,
    7.211102485656738,
    7.4833149909973145
]


def test_embeddings(embeddings_fifu, embeddings_text, embeddings_text_dims):
    # Check that we cover all words from all embedding below.
    assert len(embeddings_fifu.vocab()) == 7
    assert len(embeddings_text.vocab()) == 7
    assert len(embeddings_text_dims.vocab()) == 7

    # Check that the finalfusion embeddings have the correct dimensionality
    # The correct dimensionality of the other embedding types is asserted
    # in the pairwise comparisons below.
    assert embeddings_fifu.matrix_copy().shape == (7, 10)
    
    for embedding in embeddings_fifu:
        assert numpy.allclose(
            embedding.embedding, embeddings_text[embedding.word]), "FiFu and text embedding mismatch"
        assert numpy.allclose(
            embedding.embedding, embeddings_text_dims[embedding.word]), "FiFu and textdims embedding mismatch"


def test_embeddings_with_norms_oov(embeddings_fifu):
    assert embeddings_fifu.embedding_with_norm(
        "Something out of vocabulary") is None


def test_indexing(embeddings_fifu):
    assert embeddings_fifu["one"] is not None
    with pytest.raises(KeyError):
        embeddings_fifu["Something out of vocabulary"]


def test_embeddings_oov(embeddings_fifu):
    assert embeddings_fifu.embedding("Something out of vocabulary") is None


def test_norms(embeddings_fifu):
    for embedding, norm in zip(
            embeddings_fifu, TEST_NORMS):
        assert pytest.approx(
            embedding.norm) == norm, "Norm fails to match!"
