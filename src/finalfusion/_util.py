# pylint: disable=missing-module-docstring
import numpy as np

from finalfusion.norms import Norms
from finalfusion.storage import NdArray


def _normalize_ndarray_storage(storage: NdArray) -> Norms:
    norms = np.linalg.norm(storage, axis=1)
    storage /= norms[:, None]
    return Norms(norms)
