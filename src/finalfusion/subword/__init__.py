"""
Subword Indexers

This module provides access to subword indexers and a method to extract ngrams from strings.
"""

from finalfusion.subword.explicit_indexer import ExplicitIndexer
from finalfusion.subword.hash_indexers import FastTextIndexer, FinalfusionHashIndexer
from finalfusion.subword.ngrams import ngrams

__all__ = [
    'ExplicitIndexer', 'FastTextIndexer', 'FinalfusionHashIndexer', 'ngrams'
]
