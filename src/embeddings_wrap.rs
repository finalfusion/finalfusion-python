use finalfusion::norms::NdNorms;
use finalfusion::prelude::*;
use finalfusion::storage::CowArray1;

pub enum EmbeddingsWrap {
    NonView(Embeddings<VocabWrap, StorageWrap>),
    View(Embeddings<VocabWrap, StorageViewWrap>),
}

impl EmbeddingsWrap {
    pub fn storage(&self) -> &Storage {
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

    pub fn embedding(&self, word: &str) -> Option<CowArray1<f32>> {
        use EmbeddingsWrap::*;
        match self {
            View(e) => e.embedding(word),
            NonView(e) => e.embedding(word),
        }
    }
}
