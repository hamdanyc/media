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

# set status ext. tables

new.cat <- FALSE
new.media <- FALSE
new.article <- TRUE
pal2 <- brewer.pal(8,"Dark2")

# Read articles files ---------------------------------------------------------

# My Today ----------------------------------------------------------------

if (new.article) {
  mytoday <-
    read_csv(
      "mytoday.csv",
      col_types = cols(
        headline = col_skip(),
        `headline-href` = col_skip(),
        pubdate = col_skip()
      )
    )
  
  # break the text into individual tokens
  
  mytoday <- mytoday %>%
    unnest_tokens(word, article)
  
  mytoday[, 2] <- "Malaysia Today"
  names(mytoday)[2] = "src"
}

# Utusan Melayu ----------------------------------------------------------------

if (new.article) {
  utusan <-
    read_csv(
      "utusan_melayu.csv",
      col_types = cols(
        headline = col_skip(),
        `headline-href` = col_skip(),
        pubdate = col_skip()
      )
    )
  
  # break the text into individual tokens
  
  utusan <- utusan %>%
    unnest_tokens(word, artikel)
  
  utusan[, 2] <- "Utusan Melayu"
  names(utusan)[2] = "src"
}

# Berita Harian -----------------------------------------------------------

if (new.article) {
  beritaharian <- read_csv(
    "beritaharian.csv",
    col_types = cols(
      datePub = col_skip(),
      headlines = col_skip(),
      newslink = col_skip()
    )
  )
  # break the text into individual tokens
  
  beritaharian <- beritaharian %>%
    unnest_tokens(word, article)
}

# Keadilan Daily ----------------------------------------------------------

if (new.article) {
  keadilandaily <-
    read_csv(
      "keadilandaily.csv",
      col_types = cols(
        datepub = col_skip(),
        headline = col_skip(),
        `headline-href` = col_skip()
      )
    )
  
  # break the text into individual tokens
  
  keadilandaily <- keadilandaily %>%
    unnest_tokens(word, article)
  
  keadilandaily[, 2] <- "Keadilan Daily"
  names(keadilandaily)[2] = "src"
}

# The Star ----------------------------------------------------------------

if (new.article) {
  thestar <-
    read_csv(
      "thestar.csv",
      col_types = cols(
        headline = col_skip(),
        `headline-href` = col_skip(),
        pubdate = col_skip()
      )
    )
  
  # break the text into individual tokens
  
  thestar <- thestar %>%
    unnest_tokens(word, article)
  
  thestar[, 2] <- "The Star"
  names(thestar)[2] = "src"
}

# The Sun Daily -----------------------------------------------------------

if (new.article) {
  thesun <-
    read_csv(
      "thesun.csv",
      col_types = cols(
        headline = col_skip(),
        `headline-href` = col_skip(),
        pubdate = col_skip()
      )
    )
  # break the text into individual tokens
  
  thesun <- thesun %>%
    unnest_tokens(word, article)
  
  thesun[, 2] <- "Sun Daily"
  names(thesun)[2] = "src"
}

# Lim Kit Siang's Blog ------------------------------------------------------

if (new.article) {
  lks <-
    read_csv(
      "limkitsiang.csv",
      col_types = cols(
        headline = col_skip(),
        `headline-href` = col_skip(),
        pubdate = col_skip()
      )
    )
  
  # break the text into individual tokens
  
  lks <- lks %>%
    unnest_tokens(word, article)
  
  lks[, 2] <- "Lim Kit Siang"
  names(lks)[2] = "src"
}

# Merge articles -------------------------------------------------------------

if (new.article) textDf <- rbind(mytoday,lks,utusan,beritaharian,
                                 thestar,keadilandaily,thesun)

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
}

# Get Media:Source:Cat -----------------------------------------------------------

if (new.media) media <- read_csv("media.csv")

# Cleanup -----------------------------------------------------------------

if (new.article) {
  
  textDf <- textDf %>%
    filter(
      !str_detect(word, "[0-9]"),
      !str_detect(word, "link"),!str_detect(word, "taboola")
    )
  
  # load custom_stopwords:malay
  # load once
  load("stopwordMalay.Rdata")
  
  # load stop_word english
  data(stop_words)
  
  # remove stop words
  textDf <- textDf %>%
    anti_join(stop_words)
  
  textDf <- textDf %>%
    anti_join(stopwords_malay)
}


# Analysis ----------------------------------------------------------------

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

wcat <- wc %>%
  inner_join(cat.term) %>%
  select(Kategori, src, word, n)

wcat %>%
  filter(Kategori == "Sosial", src == "Lim Kit Siang") %>%
  select(word,Kategori,n) %>%
    with(wordcloud(word, n, max.words = 25, min.freq = 3,
        scale = c(0.5, 3),  colors=pal2))

# Save Data ---------------------------------------------------------------

save.image(file="media.RData")

# Footer ------------------------------------------------------------------

# new word for data dictionary

wlks <- wc %>% filter((n>5 & n<31),src=="Lim Kit Siang")
wrpk <- wc %>% filter((n>5 & n<31),src=="Malaysia Today")
names(wrpk)[1] = "r"
names(wrpk)[3] = "p"

inner_join(wlks,wrpk) %>%
  select(word) %>%
  write.csv(file = "pol.csv")

# Topic modeling ------------------------------------------------------------

# Latent Dirichlet allocation (LDA)

library(topicmodels)

data("AssociatedPress")
# set a seed so that the output of the model is predictable
ap_lda <- LDA(AssociatedPress, k = 2, control = list(seed = 1234))
ap_lda

# Word-topic probabilities

library(tidytext)

ap_topics <- tidy(ap_lda, matrix = "beta")

library(ggplot2)
library(dplyr)

ap_top_terms <- ap_topics %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

ap_top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()
