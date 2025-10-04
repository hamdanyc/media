# binmy.R
# try similar word with modelAnalysis.R
## @knitr sentiment

# Init --------------------------------------------------------------------

library(tidytext)
library(tidyr)
library(dplyr)
library(readr)
library(stringr)

load("newsdaily.RData")
load("stopwordMalay.RData")
load("binmy.RData")

mynews <- c("agendadaily", "amanahdaily", "antarapos", "astroawani", "amanahdaily", "beritaharian",
            "bernama", "harakah", "hmetro", "keadilandaily", "hmetro", "kosmo", "malaysiadateline", 
            "malaysianaccess","malaysiakini", "roketkini", "sinarharian", "umnoonline", "utusan")

# binMy <- news.today %>%
#   filter(src %in% mynews) %>%
#   select(article) %>%
#   unnest_tokens(word, article) %>%
#   anti_join(stopword_malay)
# 
# # remove numbers, duplicate
# binMy <- binMy %>%
#   filter(str_detect(word,"[[:alpha:]]")) %>%
#   filter(!str_detect(word,"[[:cntrl:]]")) %>%
#   unique()

# Learn it ----------------------------------------------------------------

wc <- news.today %>% 
  filter(src %in% mynews) %>%
  select(src, article) %>% 
  unnest_tokens(word, article) %>%
  group_by(src, word) %>%
  anti_join(stopword_malay) %>%
  filter(str_detect(word,"[[:alpha:]]")) %>%
  filter(!str_detect(word,"[[:cntrl:]]")) %>%
  count()

low.idf <- 3.0e-04
low.n <- 4

wcf <- wc %>% 
  ungroup(src, word) %>% 
  bind_tf_idf(word, src, n)
  # filter(tf_idf > low.idf & n < low.n)
summary(wcf)

wcf.anti <- wcf %>% 
  filter(tf_idf >= 0.005 & tf_idf <= 0.03) %>% 
  # filter(tf_idf > 0.02) %>% 
  filter(n < 3) %>% 
  anti_join(binmy) 

wcf.anti %>% 
  summary()

wcf.anti %>% 
  select(word) %>% 
  write.csv(file = "binMy.csv", row.names = FALSE, quote = FALSE)

# Add Entry ---------------------------------------------------------------

binmy.add <- read_csv("binMy.csv")

bmy.new <- binmy.add %>% 
  left_join(binmy)

binmy <- binmy %>% 
  rbind(bmy.new)

binmy <- unique(binmy)
save(binmy,file = "binmy.RData")

# Verify by Title ---------------------------------------------------------

news.tmy <- news.today %>% 
  filter(src %in% mynews) %>% 
  select(src, headlines, article) %>% 
  group_by(headlines) %>% 
  unnest_tokens(word, article)

news.smy <- news.tmy %>%
  inner_join(binmy) %>%
  group_by(headlines) %>% 
  count(sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

lookat <- "‘ Isn’t 10 Years Enough ? ’ Woman Asks Penangites Burning Questions in Viral Video"
whatisit <- news.tmy %>% 
  inner_join(wcf) %>%
  anti_join(binmy, by = "word") %>% 
  filter(headlines == lookat) %>% 
  filter(n < 6) %>%
  group_by(word) %>%
  select(headlines, word, n)

summary(whatisit)

whatisit <- news.tmy %>% 
  inner_join(wcf) %>%
  left_join(binmy, by = "word") %>% 
  filter(headlines == lookat) %>% 
  filter(n < 6) %>%
  group_by(word) %>%
  select(headlines, word, n, sentiment)
