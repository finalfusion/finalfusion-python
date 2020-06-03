# pylint: disable=missing-module-docstring
from typing import List

import numpy as np

from finalfusion.norms import Norms


def _normalize_matrix(storage: np.ndarray) -> Norms:
    norms = np.linalg.norm(storage, axis=1)
    storage /= norms[:, None]
    return Norms(norms)


__all__ = []  # type: List[str]
