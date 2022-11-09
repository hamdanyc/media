# newsSetmnt.R
## @knitr sentiment -- link to chunk sentiment

library(tidytext)
library(tidyr)
library(dplyr)

# load("newsdaily.RData")
# load("binmy.RData")  # create by binmy.R
# load("bandar.RData")

news.eng <- c("nst", "thestar", "theedge", "dailyexpress","malaysiainsight", "malaysiachronicle",
              "malaysiandigest", "sinchew","themalaymailonline", "thesundaily",
              "borneopost", "fmt", "selangortimes")
news.my <- c("agendadaily","amanahdaily","airtimes","antarapos","astroawani","amanahdaily","beritaharian",
             "bernama", "harakah", "hmetro", "keadilandaily", "hmetro", "kosmo", "malaysiadateline", 
             "malaysianaccess","malaysiakini", "roketkini", "sinarharian","sarawakvoice", "umnoonline", "utusan")
positive <- 0
negative <- 0
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

news.tmy <- news.today %>% 
  filter(src %in% news.my) %>% 
  select(src, headlines, article) %>% 
  group_by(headlines) %>% 
  unnest_tokens(word, article)

news.smy <- news.tmy %>%
  inner_join(binmy) %>%
  group_by(headlines) %>% 
  count(sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

news.stm <- news.stm %>% 
  rbind(news.smy)