Quickstart
==========

Install
-------

You can :doc:`install <install>` ``finalfusion`` through:

.. code-block:: bash

   pip install finalfusion

Package
-------

And use embeddings by:

.. code-block:: python

   import finalfusion
   # loading from different formats
   w2v_embeds = finalfusion.load_word2vec("/path/to/w2v.bin")
   text_embeds = finalfusion.load_text("/path/to/embeds.txt")
   text_dims_embeds = finalfusion.load_text_dims("/path/to/embeds.dims.txt")
   fasttext_embeds = finalfusion.load_fasttext("/path/to/fasttext.bin")
   fifu_embeds = finalfusion.load_finalfusion("/path/to/embeddings.fifu")

   # serialization to formats works similarly
   finalfusion.compat.write_word2vec("to_word2vec.bin", fifu_embeds)

   # embedding lookup
   embedding = fifu_embeds["Test"]

   # reading an embedding into a buffer
   import numpy as np
   buffer = np.zeros(fifu_embeds.storage.shape[1], dtype=np.float32)
   fifu_embeds.embedding("Test", out=buffer)

   # similarity and analogy query
   sim_query = fifu_embeds.word_similarity("Test")
   analogy_query = fifu_embeds.analogy("A", "B", "C")

   # accessing the vocab and printing the first 10 words
   vocab = fifu_embeds.vocab
   print(vocab.words[:10])

   # SubwordVocabs give access to the subword indexer:
   subword_indexer = vocab.subword_indexer
   print(subword_indexer.subword_indices("Test", with_ngrams=True))

   # accessing the storage and calculate its dot product with an embedding
   res = embedding.dot(fifu_embeds.storage)

   # printing metadata
   print(fifu_embeds.metadata)

``finalfusion`` exports most commonly used functions and types in the top level.
See :doc:`Top-Level Exports <modules/re-exports>` for an overview.

The full API documentation can be found :doc:`here <modules/api>`.

Conversion
----------

``finalfusion`` also comes with a conversion tool to convert between supported file formats
and from bucket subword embeddings to explicit subword embeddings:

.. code-block:: bash

   $ ffp-convert -f fasttext from_fasttext.bin -t finalfusion to_finalfusion.fifu
   $ ffp-bucket-to-explicit buckets.fifu explicit.fifu

See :doc:`Scripts<finalfusion.scripts>`

Similarity and Analogy
----------------------

.. code-block:: bash

   $ echo Tübingen | ffp-similar embeddings.fifu
   $ echo Tübingen Stuttgart Heidelberg | ffp-analogy embeddings.fifu

See :doc:`Scripts<finalfusion.scripts>`