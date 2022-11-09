# news_prep.R
# a trained data
# use with modelAnalysis.R

# Init --------------------------------------------------------------------
library(readtext)
library(wordVectors)
library(dplyr)
library(textreg)
library(tm)

# prepare trained data -----
# Get a List of all files in directory named with a key word, say all `.pdf` files
# data <- lapply(filenames[1:15], function(x) pdf_text(x)) %>% 
#   unlist()
# path <- paste0(getwd(),"/txt")
# filenames <- list.files(path=path, pattern="*.html", full.names=TRUE)
# name.vec.bin <- "biopharma.bin"
# data <- lapply(filenames, function(x) readtext(x))
load("newsdb.RData")

# Building test data (model) ----
# read in model as read.vectors("vector.bin")
prep.txt.corp <- textreg::clean.text(VCorpus(VectorSource(df$article)))
prep.txt <- quanteda::corpus(prep.txt.corp)
writeLines(prep.txt,"prep.txt")

# Train data ----
train_word2vec("prep.txt",name.vec.bin, window = 10, min_count = 10, force = T)

# read model ----
model <- read.vectors("biopharma.bin")

# find closet word ----
# closest_to(demo_vectors,~ "guy" - "man" + "woman")
elm <- c("growth", "management", "quality", "customer", "market", "research", "business", "innovation","competition","problem","issue")
mod_str <- paste(elm,collapse = "+")
closest_to(model,elm,n=30)
closest_to(model,~ "growth"+"management"+"quality"+"customer"+"market"+"research"+"business"+"innovation"+"competition"+"problem"+"issue",25)
closest_to(model,"management")

# Save Objects ----
save.image(file = "newsdb.RData")

