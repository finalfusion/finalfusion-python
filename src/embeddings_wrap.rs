use finalfusion::norms::NdNorms;
use finalfusion::prelude::*;
use finalfusion::storage::Storage;
use ndarray::{CowArray, Ix1};

pub enum EmbeddingsWrap {
    NonView(Embeddings<VocabWrap, StorageWrap>),
    View(Embeddings<VocabWrap, StorageViewWrap>),
}

impl EmbeddingsWrap {
    pub fn storage(&self) -> &dyn Storage {
        use EmbeddingsWrap::*;
        match self {
            NonView(e) => e.storage(),
            View(e) => e.storage(),
        }
    }

    pub fn vocab(&self) -> &VocabWrap {
        use EmbeddingsWrap::*;
        match self {
            NonView(e) => e.vocab(),
            View(e) => e.vocab(),
        }
    }

    pub fn norms(&self) -> Option<&NdNorms> {
        use EmbeddingsWrap::*;
        match self {
            NonView(e) => e.norms(),
            View(e) => e.norms(),
        }
    }

    pub fn embedding(&self, word: &str) -> Option<CowArray<f32, Ix1>> {
        use EmbeddingsWrap::*;
        match self {
            View(e) => e.embedding(word),
            NonView(e) => e.embedding(word),
        }
    }

    pub fn view(&self) -> Option<&Embeddings<VocabWrap, StorageViewWrap>> {
        match self {
            EmbeddingsWrap::NonView(_) => None,
            EmbeddingsWrap::View(storage) => Some(storage),
        }
    }
}
