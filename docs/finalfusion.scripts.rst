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
   usage: ffp-convert [-h] [-f INPUT_FORMAT] [-t OUTPUT_FORMAT] INPUT OUTPUT

   Convert embeddings.

   positional arguments:
     INPUT                 Input embeddings
     OUTPUT                Output path

   optional arguments:
     -h, --help            show this help message and exit
     -f INPUT_FORMAT, --from INPUT_FORMAT
                           Valid choices: ['word2vec', 'finalfusion', 'fasttext',
                           'text', 'textdims'] Default: 'word2vec'
     -t OUTPUT_FORMAT, --to OUTPUT_FORMAT
                           Valid choices: ['word2vec', 'finalfusion', 'fasttext',
                           'text', 'textdims'] Default: 'finalfusion'

.. Similar:

Similar
-------

``ffp-similar`` supports similarity queries:

.. code-block:: bash

   $ ffp-similar --help
   usage: ffp-similar [-h] [-f INPUT_FORMAT] [-k K] EMBEDDINGS [input]

   Similarity queries.

   positional arguments:
     EMBEDDINGS            Input embeddings
     input                 Optional input file with one word per line. If
                           unspecified reads from stdin


   optional arguments:
     -h, --help            show this help message and exit
     -f INPUT_FORMAT, --format INPUT_FORMAT
                           Valid choices: ['word2vec', 'finalfusion', 'fasttext',
                           'text', 'textdims'] Default: 'finalfusion'
     -k K                  Number of neighbours. Default: 10

.. Analogy:

Analogy
-------

``ffp-analogy`` answers analogy queries:

.. code-block:: bash

   $ ffp-analogy --help
   usage: ffp-analogy [-h] [-f INPUT_FORMAT] [-i {a,b,c} [{a,b,c} ...]] [-k K]
                      EMBEDDINGS [input]

   Analogy queries.

   positional arguments:
     EMBEDDINGS            Input embeddings
     input                 Optional input file with 3 words per line. If
                           unspecified reads from stdin

   optional arguments:
     -h, --help            show this help message and exit
     -f INPUT_FORMAT, --format INPUT_FORMAT
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

   $ ffp-bucket-to-explicit
   usage: ffp-bucket-to-explicit [-h] [-f INPUT_FORMAT] INPUT OUTPUT

   Convert bucket embeddings to explicit lookups.

   positional arguments:
     INPUT                 Input bucket embeddings
     OUTPUT                Output path

   optional arguments:
     -h, --help            show this help message and exit
     -f INPUT_FORMAT, --from INPUT_FORMAT
                           Valid choices: ['finalfusion', 'fasttext'] Default:
                           'finalfusion'
