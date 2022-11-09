# mediaVector.R
# artikel.txt from prepText.R

library(wordVectors)

# model
prep_word2vec(origin="artikel.txt",destination="media.txt",lowercase=T,
              bundle_ngrams=2)
train_word2vec("media.txt","media.vector.bin", force = T)
