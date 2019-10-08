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
    fifu_storage = embeddings_fifu.storage()
    # Check that the finalfusion embeddings have the correct dimensionality
    # The correct dimensionality of the other embedding types is asserted
    # in the pairwise comparisons below.
    assert fifu_storage.shape() == (7, 10)

    for embedding, storage_row in zip(embeddings_fifu, fifu_storage):
        assert numpy.allclose(
            embedding.embedding, embeddings_text[embedding.word]), "FiFu and text embedding mismatch"
        assert numpy.allclose(
            embedding.embedding, embeddings_text_dims[embedding.word]), "FiFu and textdims embedding mismatch"
        assert numpy.allclose(
            embedding.embedding, storage_row), "FiFu and storage row  mismatch"


def test_unknown_embeddings(embeddings_fifu):
    assert embeddings_fifu.embedding("OOV") is None, "Unknown lookup with no default failed"
    assert embeddings_fifu.embedding(
        "OOV", default=None) is None, "Unknown lookup with 'None' default failed"
    assert numpy.allclose(embeddings_fifu.embedding(
        "OOV", default=[10]*10), numpy.array([10.]*10)), "Unknown lookup with 'list' default failed"
    assert numpy.allclose(embeddings_fifu.embedding("OOV", default=numpy.array(
        [10.]*10)), numpy.array([10.]*10)), "Unknown lookup with array default failed"
    assert numpy.allclose(embeddings_fifu.embedding(
        "OOV", default=10), numpy.array([10.]*10)), "Unknown lookup with 'int' scalar default failed"
    assert numpy.allclose(embeddings_fifu.embedding(
        "OOV", default=10.), numpy.array([10.]*10)), "Unknown lookup with 'float' scalar default failed"
    with pytest.raises(TypeError):
        embeddings_fifu.embedding(
            "OOV", default="not working"), "Unknown lookup with 'str' default succeeded"
    with pytest.raises(ValueError):
        embeddings_fifu.embedding(
            "OOV", default=[10.]*5), "Unknown lookup with incorrectly shaped 'list' default succeeded"
    with pytest.raises(ValueError):
        embeddings_fifu.embedding(
            "OOV", default=numpy.array([10.]*5)), "Unknown lookup with incorrectly shaped array default succeeded"
    with pytest.raises(ValueError):
        embeddings_fifu.embedding(
            "OOV", default=range(7)), "Unknown lookup with iterable default with incorrect number succeeded"


def test_embeddings_pq(similarity_fifu, similarity_pq):
    for embedding in similarity_fifu:
        embedding_pq = similarity_pq.embedding("Berlin")
        assert numpy.allclose(embedding.embedding, embedding_pq,
                              atol=0.3), "Embedding and quantized embedding mismatch"


def test_embeddings_pq_mmap(similarity_fifu, similarity_pq_mmap):
    for embedding in similarity_fifu:
        embedding_pq = similarity_pq_mmap.embedding("Berlin")
        assert numpy.allclose(embedding.embedding, embedding_pq,
                              atol=0.3), "Embedding and quantized embedding mismatch"


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
