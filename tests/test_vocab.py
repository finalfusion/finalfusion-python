def test_embeddings_with_norms_oov(embeddings_fifu):
    vocab = embeddings_fifu.vocab()
    assert vocab.item_to_indices("Something out of vocabulary") is None
