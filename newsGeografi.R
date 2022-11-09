# newsGeografi.R

library(tidytext)
library(tidyr)
library(dplyr)

load("newsdaily.RData")
load("binmy.RData")
load("bandar.RData")
load("newsDailyKPI.RData")

source("newsSetmnt.R")  # set sentiment from news.stm

news.bigrm <- news.today %>% 
  select(src, datePub, headlines, article) %>% 
  group_by(headlines) %>% 
  unnest_tokens(word, article, token = "ngrams", n = 2)

news.geo <- news.bigrm %>%
  inner_join(news.loc) %>%
  inner_join(neg.my) %>%
  group_by(src, datePub, headlines) %>%
  unique() %>% 
  summarise(lokasi = first(word), Negeri = first(neg.desc))

datePub <- format(Sys.Date(), "%Y/%m/%d")
news.geo %>% 
  # inner_join(daily.kpi, by = "headlines") %>% not implemented
  inner_join(news.stm, by = "headlines") %>% 
  write.table(file="newsGeografi.csv", row.names = FALSE, sep = "|", quote=TRUE)
