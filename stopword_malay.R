#Loading the sample words file.
library(readr)
library(tidytext)

stopword_malay <- read.csv("stopword_malay.csv", header = TRUE)
stopword_malay$word <- as.character(stopword_malay$word)

# Append new word ---------------------------------------------------------

load("stopwordmalay.RData")
newdat <- data.frame(word = rbind("sebelas","belas","jutaan", "ribuan"))
stopword_malay <- rbind(stopword_malay,newdat)
save(stopword_malay, file="stopwordMalay.RData")
