# Init --------------------------------------------------------------------

library(dplyr)
library(tidytext)
library(stringr)
library(ggplot2)
library(wordcloud)
library(RColorBrewer)
library(readr)

# get utiliti functions
source("../function/myRfun.R")

# load stop_word english/Malay
data(stop_words)
load("stopwordMalay.RData")

stopwords_malay <- data.frame(custom_stopwords)
names(stopwords_malay)[1] <- "word"

# set status ext. tables

new.cat <- TRUE
new.media <- TRUE
new.article <- TRUE
pal2 <- brewer.pal(8,"Dark2")

# Read ggNews.csv files ---------------------------------------------------------

if (new.article) {
  ggNews <-  read_csv("ggNews.csv",
             col_types = cols(datePub = col_skip(),
                              headlines = col_skip(),
                              newslink = col_skip())
    )
  
# break the text into individual tokens
ggNews <- ggNews %>%
  unnest_tokens(word, article)
}
  
# Text Corpus -------------------------------------------------------------

if (new.article) textDf <- ggNews

# Read tbl cat/media ------------------------------------------------------------

# read category Keselamatan, Politik, Pertahanan
# File: category; Fields word, category

if (new.cat) {
  cat <- read_csv("cat.csv")
  
  cat.def <- data.frame(cat[, 1], "Keselamatan")
  names(cat.def)[1] = "word"
  names(cat.def)[2] = "Kategori"
  cat.pol <- data.frame(cat[, 2], "Politik")
  names(cat.pol)[1] = "word"
  names(cat.pol)[2] = "Kategori"
  cat.sos <- data.frame(cat[, 3], "Sosial")
  names(cat.sos)[1] = "word"
  names(cat.sos)[2] = "Kategori"
  
  cat.term <- rbind(cat.def, cat.pol, cat.sos)
  cat.term <- na.omit(cat.term)
}

# Get Media:Source:Cat -----------------------------------------------------------

if (new.media) load("media.RData")

media$src <- as.character(media$src)
media$cat <- as.character(media$cat)
media$css <- as.character(media$css)
media$rat <- as.numeric(as.character(media$rat))

# Cleanup -----------------------------------------------------------------
# remove stopwords

if (new.article) {
  textDf <- textDf %>%
    anti_join(stop_words)
  
  textDf <- textDf %>%
    anti_join(stopwords_malay)
}
# names(textDf)[1] <- "src"

# Analyse ----------------------------------------------------------------
# create word count from articles

wc <- textDf %>% 
  select(src, word) %>% 
  count(src, word)

wc100 <- wc %>% 
  filter(n > 3 & n < 100)

wc100 <- na.omit(wc100)

result <- wc100 %>%   
  inner_join(cat.term) %>%
  inner_join(media) %>%
  select(Kategori, src, n, rat)

wr <- result %>%
  select(Kategori,src,rat,n) %>% 
  group_by(Kategori, src) %>%
  summarise (n = n()) %>%
  mutate(pct = n / sum(n))

ws <- wr %>%
  inner_join(media) %>%
  mutate(score = rat*pct) %>%
  select(Kategori,src,rat,pct,score) %>% 
  group_by(Kategori)

aggregate(score ~ src+Kategori, ws, sum)
idx <- aggregate(score ~ Kategori, ws, sum)

# Word Cloud --------------------------------------------------------------

wcld <- wc %>%
  inner_join(cat.term) %>%
  select(Kategori, src, word, n) %>% 
  filter(!duplicated(word))

wcld %>%
  filter(Kategori == "Keselamatan") %>%
  # filter(src == "sinarharian") %>%
  select(word,Kategori,n) %>%
    with(wordcloud(word, n, max.words = 25, min.freq = 3,
        scale = c(0.5, 3),  colors=pal2))
