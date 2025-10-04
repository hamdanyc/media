# topicModel.R

library(topicmodels)
library(tidytext)
library(readr)
library(ggplot2)
library(dplyr)

# Read source -------------------------------------------------------------
# Utusan Melayu
utusan <- read_csv("beritaharian.csv", 
              col_types = cols(datePub = col_skip(), 
              headlines = col_skip(), newslink = col_skip()))

load("stopwordMalay.RData")

# break the text into individual tokens
words_counts <- utusan %>%
  unnest_tokens(word, article)

words_counts <- words_counts %>% 
  anti_join(stopword_malay) %>%
  count(src, word, sort = TRUE) %>%
  ungroup()

# Cast to DTM -------------------------------------------------------------
news_dtm <- words_counts %>%
  cast_dtm(src, word, n)

# news_dtm <- wc %>%
#   cast_dtm(src, word, n)

# Topic modeling ------------------------------------------------------------
# Latent Dirichlet allocation (LDA)

# set a seed so that the output of the model is predictable
news_lda <- LDA(news_dtm, k = 2, control = list(seed = 1234))
news_lda

# Word-topic probabilities
news_topics <- tidy(news_lda, matrix = "beta")

news_top_terms <- news_topics %>%
  group_by(topic) %>%
  top_n(17, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

news_top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()
