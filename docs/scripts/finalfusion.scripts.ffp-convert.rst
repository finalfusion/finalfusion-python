Scripts
=======

Convert
-------

After installing ``finalfusion``, conversion between all supported embedding formats is possible:

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
