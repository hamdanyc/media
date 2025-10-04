# media2017.R


# Init --------------------------------------------------------------------

library(lubridate)
library(dplyr)
library(tidytext)
library(tidyr)

load(file = "media_2017.RData")
load("binmy.RData")

thenews <- c("agendadaily",
             "amanahdaily",
             "airtimes",
             "astroawani",
             "beritaharian",
             "bernama",
             "borneopost",
             "fmt",
             "harakah",
             "hmetro",
             "keadilandaily",
             "kosmo",
             "malaysianaccess",
             "malaysiachronicle",
             "malaysiadateline",
             "malaysiandigest",
             "malaysiakini",
             "malaysiainsight",
             "nst",
             "roketkini",
             "sarawakvoice",
             "sinarharian",
             "sinchew",
             "theedge",
             "themalaymailonline",
             "theStar",
             "thesundaily",
             "umnoonline",
             "utusan",
             "newstwit")

news.eng <- c("nst", "thestar", "theedge", "dailyexpress","malaysiainsight", "malaysiachronicle",
              "malaysiandigest", "sinchew","themalaymailonline", "thesundaily",
              "borneopost", "fmt", "selangortimes")
news.my <- c("agendadaily","amanahdaily","airtimes","antarapos","astroawani","amanahdaily","beritaharian",
             "bernama", "harakah", "hmetro", "keadilandaily", "hmetro", "kosmo", "malaysiadateline", 
             "malaysianaccess","malaysiakini", "roketkini", "sinarharian", "umnoonline", "utusan")
positive <- 0
negative <- 0

# media_2017_18$datepub <- as.Date(media_2017_18$datepub,"%d/%m/%Y")
media_2017_18$headlines <- iconv(media_2017_18$headlines, to="UTF-8")

media_2017_18 <- media_2017_18 %>% 
  filter(src %in% thenews)


# Calc Sentiment ----------------------------------------------------------

article.eng <- media_2017_18 %>% 
  filter(src %in% news.eng) %>% 
  select(src,headlines,datepub,article) %>% 
  group_by(headlines) %>% 
  unnest_tokens(word, article)

article.my <- media_2017_18 %>% 
  filter(src %in% news.my) %>% 
  select(src,headlines,datepub,article) %>% 
  group_by(headlines) %>% 
  unnest_tokens(word, article)

sent.eng <- article.eng %>%
  inner_join(get_sentiments("bing")) %>%
  group_by(src,headlines,datepub) %>% 
  count(sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

sent.my <- article.my %>%
  inner_join(binmy) %>%
  group_by(src,headlines,datepub) %>% 
  count(sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

news.data <- rbind(sent.eng,sent.my)

# Write Data --------------------------------------------------------------

write.csv(news.data,file = "news_open.csv",row.names = FALSE)
