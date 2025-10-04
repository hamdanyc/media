# newsSentiment.R
## @knitr sentiment

library(tidytext)
library(tidyr)

load("newsdaily.RData")

news.eng <- c("nst", "thestar", "theedge", "roketkini", "dailyexpress",
              "malaysiandigest", "sinchew","themalaymailonline", "thesundaily",
               "fmt", "selangortimes")

news.tidy <- news.today %>% 
  filter(src %in% news.eng) %>% 
  select(src, headlines, article) %>% 
  group_by(headlines) %>% 
  unnest_tokens(word, article)

news.stm <- news.tidy %>%
  inner_join(get_sentiments("bing")) %>%
  group_by(headlines) %>% 
  count(sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

## @knitr daily.kpi
daily.kpi <- news.tidy %>%
  inner_join(get_sentiments("bing")) %>%
  inner_join(cat.term) %>% 
  group_by(Kategori) %>% 
  count(sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

