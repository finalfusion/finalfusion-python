"""
Finalfusion Embeddings
"""
from os import PathLike
from typing import Optional, Tuple, List, Union, Any

import numpy as np

from finalfusion.io import Chunk, Header, _read_chunk_header, ChunkIdentifier, \
    FinalfusionFormatError, _read_required_chunk_header
from finalfusion.metadata import Metadata
from finalfusion.norms import Norms
from finalfusion.storage import Storage, NdArray
from finalfusion.vocab import Vocab, SimpleVocab, FinalfusionBucketVocab


class Embeddings:  # pylint: disable=too-many-instance-attributes
    """
    Embeddings class.

    Embeddings always contain a :class:`~finalfusion.storage.storage.Storage` and
    :class:`~finalfusion.vocab.vocab.Vocab`. Optional chunks are
    :class:`~finalfusion.norms.Norms` corresponding to the embeddings of the in-vocab tokens and
    :class:`~finalfusion.metadata.Metadata`.

    Embeddings can be retrieved through three methods:

    1. :meth:`Embeddings.embedding` allows to provide a default value and returns
       this value if no embedding could be found.
    2. :meth:`Embeddings.__getitem__` retrieves an embedding for the query but
       raises an exception if it cannot retrieve an embedding.
    3. :meth:`Embeddings.embedding_with_norm` requires a :class:`~finalfusion.norms.Norms`
       chunk and returns an embedding together with the corresponding L2 norm.

    Embeddings are composed of the 4 chunk types:

    1. :class:`~finalfusion.storage.Storage` *(required)*:
        * :class:`~finalfusion.storage.ndarray.NdArray`
    2. :class:`~finalfusion.vocab.Vocab` *(required)*:
        * :class:`~finalfusion.vocab.simple_vocab.SimpleVocab`,
          :class:`~finalfusion.vocab.subword.FinalfusionBucketVocab`
    3. :class:`~finalfusion.metadata.Metadata`
    4. :class:`~finalfusion.norms.Norms`

    Examples
    --------
    >>> storage = NdArray(np.float32(np.random.rand(2, 10)))
    >>> vocab = SimpleVocab(["Some", "words"])
    >>> metadata = Metadata({"Some": "value", "numerical": 0})
    >>> norms = Norms(np.float32(np.random.rand(2)))
    >>> embeddings = Embeddings(storage=storage, vocab=vocab, metadata=metadata, norms=norms)
    >>> embeddings.vocab.words
    ['Some', 'words']
    >>> np.allclose(embeddings["Some"], storage[0])
    True
    >>> try:
    ...     embeddings["oov"]
    ... except KeyError:
    ...     True
    True
    >>> _, n = embeddings.embedding_with_norm("Some")
    >>> np.isclose(n, norms[0])
    True
    >>> embeddings.metadata
    {'Some': 'value', 'numerical': 0}
    """
    def __init__(self,
                 storage: Storage,
                 vocab: Vocab,
                 norms: Optional[Norms] = None,
                 metadata: Optional[Metadata] = None):
        """
        Initialize Embeddings.

        Initializes Embeddings with the given chunks.

        :Conditions:
            The following conditions need to hold if the respective chunks are passed.

            * Chunks need to have the expected type.
            * ``vocab.idx_bound == storage.shape[0]``
            * ``len(vocab) == len(norms)``
            * ``len(norms) == len(vocab) and len(norms) >= storage.shape[0]``

        Parameters
        ----------
        storage : Storage
            Embeddings Storage.
        vocab : Vocab
            Embeddings Vocabulary.
        norms : Norms, optional
            Embeddings Norms.
        metadata : Metadata, optional
            Embeddings Metadata.

        Raises
        ------
        AssertionError
            If any of the conditions don't hold.
        """
        Embeddings._check_requirements(storage, vocab, norms, metadata)
        self._storage = storage
        self._vocab = vocab
        self._norms = norms
        self._metadata = metadata

    def __getitem__(self, item: str) -> np.ndarray:
        """
        Returns an embeddings.

        Parameters
        ----------
        item : str
            The query item.

        Returns
        -------
        embedding : numpy.ndarray
            The embedding.

        Raises
        ------
        KeyError
            If no embedding could be retrieved.

        See Also
        --------
        :func:`~Embeddings.embedding`
        :func:`~Embeddings.embedding_with_norm`
        """
        # no need to check for none since Vocab raises KeyError if it can't produce indices
        idx = self._vocab[item]
        return self._embedding(idx)[0]

    def embedding(self,
                  word: str,
                  out: Optional[np.ndarray] = None,
                  default: Optional[np.ndarray] = None
                  ) -> Optional[np.ndarray]:
        """
        Embedding lookup.

        Looks up the embedding for the input word.

        If an `out` array is specified, the embedding is written into the array.

        If it is not possible to retrieve an embedding for the input word, the `default`
        value is returned. This defaults to `None`. An embedding can not be retrieved if
        the vocabulary cannot provide an index for `word`.

        This method never fails. If you do not provide a default value, check the return value
        for None. ``out`` is left untouched if no embedding can be found and ``default`` is None.

        Parameters
        ----------
        word : str
            The query word.
        out : numpy.ndarray, optional
            Optional output array to write the embedding into.
        default: numpy.ndarray, optional
            Optional default value to return if no embedding can be retrieved. Defaults to None.

        Returns
        -------
        embedding : numpy.ndarray, optional
            The retrieved embedding or the default value.

        Examples
        --------
        >>> matrix = np.float32(np.random.rand(2, 10))
        >>> storage = NdArray(matrix)
        >>> vocab = SimpleVocab(["Some", "words"])
        >>> embeddings = Embeddings(storage=storage, vocab=vocab)
        >>> np.allclose(embeddings.embedding("Some"), matrix[0])
        True
        >>> # default value is None
        >>> embeddings.embedding("oov") is None
        True
        >>> # It's possible to specify a default value
        >>> default = embeddings.embedding("oov", default=storage[0])
        >>> np.allclose(default, storage[0])
        True
        >>> # Embeddings can be written to an output buffer.
        >>> out = np.zeros(10, dtype=np.float32)
        >>> out2 = embeddings.embedding("Some", out=out)
        >>> out is out2
        True
        >>> np.allclose(out, matrix[0])
        True

        See Also
        --------
        :func:`~Embeddings.embedding_with_norm`
        :func:`~Embeddings.__getitem__`
        """
        idx = self._vocab.idx(word)
        if idx is None:
            if out is not None and default is not None:
                out[:] = default
                return out
            return default
        return self._embedding(idx, out)[0]

    def embedding_with_norm(self,
                            word: str,
                            out: Optional[np.ndarray] = None,
                            default: Optional[Tuple[np.ndarray, float]] = None
                            ) -> Optional[Tuple[np.ndarray, float]]:
        """
        Embedding lookup with norm.

        Looks up the embedding for the input word together with its norm.

        If an `out` array is specified, the embedding is written into the array.

        If it is not possible to retrieve an embedding for the input word, the `default`
        value is returned. This defaults to `None`. An embedding can not be retrieved if
        the vocabulary cannot provide an index for `word`.

        This method raises a TypeError if norms are not set.

        Parameters
        ----------
        word : str
            The query word.
        out : numpy.ndarray, optional
            Optional output array to write the embedding into.
        default: Tuple[numpy.ndarray, float], optional
            Optional default value to return if no embedding can be retrieved. Defaults to None.

        Returns
        -------
        (embedding, norm) : EmbeddingWithNorm, optional
            Tuple with the retrieved embedding or the default value at the first index and the
            norm at the second index.

        See Also
        --------
        :func:`~Embeddings.embedding`
        :func:`~Embeddings.__getitem__`
        """
        if self._norms is None:
            raise TypeError("embeddings don't contain norms chunk")
        idx = self._vocab.idx(word)
        if idx is None:
            if out is not None and default is not None:
                out[:] = default[0]
                return out, default[1]
            return default
        # declare the norm as Any, self._embedding returns Optional[float], but above its
        # ensured norms are present, the norm is guaranteed to be float, not Optional[float]
        val = self._embedding(idx, out)  # type: Tuple[np.ndarray, Any]
        return val

    @property
    def storage(self) -> Storage:
        """
        Get the :class:`~finalfusion.storage.storage.Storage`.

        Returns
        -------
        storage : Storage
            The embeddings storage.
        """
        return self._storage

    @property
    def vocab(self) -> Vocab:
        """
        The :class:`~finalfusion.vocab.vocab.Vocab`.

        Returns
        -------
        vocab : Vocab
            The vocabulary
        """
        return self._vocab

    @property
    def norms(self) -> Optional[Norms]:
        """
        The :class:`~finalfusion.vocab.vocab.Norms`.

        :Getter: Returns None or the Norms.
        :Setter: Set the Norms.

        Returns
        -------
        norms : Norms, optional
            The Norms or None.

        Raises
        ------
        AssertionError
            if ``embeddings.storage.shape[0] < len(embeddings.norms)`` or
            ``len(embeddings.norms) != len(embeddings.vocab)``
        TypeError
            If ``norms`` is neither Norms nor None.
        """
        return self._norms

    @norms.setter
    def norms(self, norms: Optional[Norms]):
        if norms is None:
            self._norms = None
        else:
            Embeddings._norms_compat(self.storage, self.vocab, norms)
            self._norms = norms

    @property
    def metadata(self) -> Optional[Metadata]:
        """
        The :class:`~finalfusion.vocab.vocab.Metadata`.

        :Getter: Returns None or the Metadata.
        :Setter: Set the Metadata.

        Returns
        -------
        metadata : Metadata, optional
            The Metadata or None.

        Raises
        ------
        TypeError
            If ``metadata`` is neither Metadata nor None.
        """
        return self._metadata

    @metadata.setter
    def metadata(self, metadata: Optional[Metadata]):
        if metadata is None:
            self._metadata = None
        elif isinstance(metadata, Metadata):
            self._metadata = metadata
        else:
            raise TypeError("Expected 'None' or 'Metadata'.")

    def chunks(self) -> List[Chunk]:
        """
        Get the Embeddings Chunks as a list.

        The Chunks are ordered in the expected serialization order:
        1. Metadata (optional)
        2. Vocabulary
        3. Storage
        4. Norms (optional)

        Returns
        -------
        chunks : List[Chunk]
            List of embeddings chunks.
        """
        chunks = []  # type: List[Chunk]
        if self.metadata is not None:
            chunks.append(self.metadata)
        chunks.append(self.vocab)
        chunks.append(self.storage)
        if self.norms is not None:
            chunks.append(self.norms)
        return chunks

    def write(self, file: str):
        """
        Write the Embeddings to the given file.

        Writes the Embeddings to a finalfusion file at the given file.

        Parameters
        ----------
        file : str
            Path of the output file.
        """
        with open(file, 'wb') as outf:
            chunks = self.chunks()
            header = Header([chunk.chunk_identifier() for chunk in chunks])
            header.write_chunk(outf)
            for chunk in chunks:
                chunk.write_chunk(outf)

    def __contains__(self, item):
        return item in self._vocab

    def __iter__(self):
        if self._norms is not None:
            return zip(self._vocab.words, self._storage, self._norms)
        return zip(self._vocab.words, self._storage)

    def _embedding(self,
                   idx: Union[int, List[int]],
                   out: Optional[np.ndarray] = None
                   ) -> Tuple[np.ndarray, Optional[float]]:
        res = self._storage[idx]
        if res.ndim == 1:
            if out is not None:
                out[:] = res
            else:
                out = res
            if self._norms is not None:
                norm = self._norms[idx]
            else:
                norm = None
        else:
            out = np.add.reduce(res, 0, out=out, keepdims=False)
            norm = np.linalg.norm(out)
            out /= norm
        return out, norm

    @staticmethod
    def _check_requirements(storage: Storage, vocab: Vocab,
                            norms: Optional[Norms],
                            metadata: Optional[Metadata]):
        assert isinstance(storage, Storage),\
            "storage is required to be a Storage"
        assert isinstance(vocab, Vocab), "vocab is required to be a Vocab"
        assert storage.shape[0] == vocab.upper_bound,\
            "Number of embeddings needs to be equal to vocab's idx_bound"
        if norms is not None:
            Embeddings._norms_compat(storage, vocab, norms)
        assert metadata is None or isinstance(metadata, Metadata),\
            "metadata is required to be Metadata"

    @staticmethod
    def _norms_compat(storage: Storage, vocab: Vocab, norms: Norms):
        assert isinstance(norms, Norms), "norms are required to be Norms"
        assert storage.shape[0] >= len(norms),\
            "Number of embeddings needs to be greater than or equal to number of norms."
        assert len(vocab) == len(norms),\
            "Vocab length needs to be equal to number of norms."


def load_finalfusion(file: Union[str, bytes, int, PathLike],
                     mmap: bool = False) -> Embeddings:
    """
    Read embeddings from a file in finalfusion format.

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Path to a file with embeddings in finalfusoin format.
    mmap : bool
        Toggles memory mapping the storage buffer.

    Returns
    -------
    embeddings : Embeddings
        The embeddings from the input file.
    """
    with open(file, 'rb') as inf:
        _ = Header.read_chunk(inf)
        chunk_id, _ = _read_required_chunk_header(inf)
        norms = None
        metadata = None

        if chunk_id == ChunkIdentifier.Metadata:
            metadata = Metadata.read_chunk(inf)
            chunk_id, _ = _read_required_chunk_header(inf)

        if chunk_id == ChunkIdentifier.SimpleVocab:
            vocab = SimpleVocab.read_chunk(inf)  # type: Vocab
        elif chunk_id == ChunkIdentifier.BucketSubwordVocab:
            vocab = FinalfusionBucketVocab.read_chunk(inf)
        else:
            raise FinalfusionFormatError(
                f'Expected vocab chunk, not {str(chunk_id)}')

        chunk_id, _ = _read_required_chunk_header(inf)
        if chunk_id == ChunkIdentifier.NdArray:
            storage = NdArray.load(inf, mmap)
        else:
            raise FinalfusionFormatError(
                f'Expected storage chunk, not {str(chunk_id)}')
        maybe_chunk_id = _read_chunk_header(inf)
        if maybe_chunk_id is not None:
            if maybe_chunk_id[0] == ChunkIdentifier.NdNorms:
                norms = Norms.read_chunk(inf)
            else:
                raise FinalfusionFormatError(
                    f'Expected norms chunk, not {str(chunk_id)}')

        return Embeddings(storage, vocab, norms, metadata)
