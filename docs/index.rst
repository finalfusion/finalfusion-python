.. finalfusion documentation master file, created by
   sphinx-quickstart on Fri May  1 12:35:09 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Finalfusion in Python
=====================

``finalfusion`` is a Python package for reading, writing and using
`finalfusion <https://finalfusion.github.io>`__ embeddings, but also supports other commonly used
embeddings like fastText, GloVe and word2vec.

The Python package supports the same types of embeddings as the
`finalfusion-rust crate <https://docs.rs/finalfusion/>`__:

* Vocabulary

   * No subwords
   * Subwords

* Embedding matrix

   * Array
   * Memory-mapped
   * Quantized

* Norms
* Metadata

This package extends (de-)serialization capabilities of ``finalfusion`` :class:`~.Chunk`\ s by
allowing loading and writing single chunks. E.g. a :class:`~.Vocab` can be loaded from a
`finalfusion spec <https://finalfusion.github.io/spec>`__ file without loading the
:class:`~.Storage`. Single chunks can also be serialized to their own files
through :meth:`~.Chunk.write`. This is different from the functionality of ``finalfusion-rust``,
loading stand-alone components is only supported by the Python package. Reading will fail with
other tools from the ``finalfusion`` ecosystem.

It integrates nicely with :mod:`.numpy` since its :class:`~.Storage` types can be
treated as numpy arrays.

``finalfusion`` comes with some :doc:`scripts <finalfusion.scripts>` to convert between
embedding formats, do analogy and similarity queries and turn bucket subword embeddings
into explicit subword embeddings.

The package is implemented in Python with some ``Cython`` extensions, it is not based on bindings
to the `finalfusion-rust crate <https://github.com/finalfusion/finalfusion-rust/>`__.

Contents
--------
.. toctree::
   :hidden:

   self

.. toctree::
   :maxdepth: 2

   quickstart
   install
   modules/re-exports
   modules/api
   finalfusion.scripts

Indices and tables
------------------

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
