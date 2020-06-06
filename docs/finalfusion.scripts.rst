Scripts
=======

Installing ``finalfusion`` adds some exectuables:

    * ``ffp-convert`` for converting embeddings
    * ``ffp-similar`` for similarity queries
    * ``ffp-analogy`` for analogy queries
    * ``ffp-bucket-to-explicit`` to convert bucket subword to explicit subword embeddings

.. Convert:

Convert
-------

``ffp-convert`` makes conversion between all supported embedding formats possible:

.. code-block:: bash

   $ ffp-convert --help
   usage: ffp-convert [-h] [-f FORMAT] [-t FORMAT] INPUT OUTPUT

   Convert embeddings.

   positional arguments:
     INPUT                 Input embeddings
     OUTPUT                Output path

   optional arguments:
     -h, --help            show this help message and exit
     -f FORMAT, --from FORMAT
                           Valid choices: ['word2vec', 'finalfusion', 'fasttext',
                           'text', 'textdims'] Default: 'word2vec'
     -t FORMAT, --to FORMAT
                           Valid choices: ['word2vec', 'finalfusion', 'fasttext',
                           'text', 'textdims'] Default: 'finalfusion'

.. Similar:

Similar
-------

``ffp-similar`` supports similarity queries:

.. code-block:: bash

   $ ffp-similar --help
   usage: ffp-similar [-h] [-f FORMAT] [-k K] EMBEDDINGS [input]

   Similarity queries.

   positional arguments:
     EMBEDDINGS            Input embeddings
     input                 Optional input file with one word per line. If
                           unspecified reads from stdin


   optional arguments:
     -h, --help            show this help message and exit
     -f FORMAT, --format FORMAT
                           Valid choices: ['word2vec', 'finalfusion', 'fasttext',
                           'text', 'textdims'] Default: 'finalfusion'
     -k K                  Number of neighbours. Default: 10

.. Analogy:

Analogy
-------

``ffp-analogy`` answers analogy queries:

.. code-block:: bash

   $ ffp-analogy --help
   usage: ffp-analogy [-h] [-f FORMAT] [-i {a,b,c} [{a,b,c} ...]] [-k K]
                      EMBEDDINGS [input]

   Analogy queries.

   positional arguments:
     EMBEDDINGS            Input embeddings
     input                 Optional input file with 3 words per line. If
                           unspecified reads from stdin

   optional arguments:
     -h, --help            show this help message and exit
     -f FORMAT, --format FORMAT
                           Valid choices: ['word2vec', 'finalfusion', 'fasttext',
                           'text', 'textdims'] Default: 'finalfusion'
     -i {a,b,c} [{a,b,c} ...], --include {a,b,c} [{a,b,c} ...]
                           Specify query parts that should be allowed as answers.
                           Valid choices: ['a', 'b', 'c']
     -k K                  Number of neighbours. Default: 10

.. bucket to explicit:

Bucket to Explicit
------------------


``ffp-bucket-to-explicit`` converts bucket subword embeddings to explicit subword embeddings:

.. code-block:: bash

   $ ffp-bucket-to-explicit --help
   usage: ffp-bucket-to-explicit [-h] [-f FORMAT] INPUT OUTPUT

   Convert bucket embeddings to explicit lookups.

   positional arguments:
     INPUT                 Input embeddings
     OUTPUT                Output path

   optional arguments:
     -h, --help            show this help message and exit
     -f INPUT_FORMAT, --from FORMAT
                           Valid choices: ['finalfusion', 'fasttext'] Default:
                           'finalfusion'

Embedding Selection
-------------------

It's also possible to generate an embedding file based on an input vocabulary. For subword
vocabularies, ``ffp-select`` adds computed representations for unknown words. Subword embeddings
are converted to embeddings with a simple lookup through this script. The resulting embeddings have
an array storage.

.. code-block:: bash

   $ ffp-select --help

   usage: ffp-select [-h] [-f FORMAT] INPUT OUTPUT [WORDS]

   Build embeddings from list of words.

   positional arguments:
     INPUT                 Input embeddings
     OUTPUT                Output path
     WORDS                 List of words to include in the embeddings. One word
                           per line. Spaces permitted.Reads from stdin if
                           unspecified.

   optional arguments:
     -h, --help            show this help message and exit
     -f FORMAT, --format FORMAT
                           Valid choices: ['word2vec', 'finalfusion', 'fasttext',
                           'text', 'textdims'] Default: 'finalfusion'
     --ignore_unk, -i      Skip unrepresentable words.
     --verbose, -v         Print which tokens are skipped because they can't be
                           represented to stderr.
