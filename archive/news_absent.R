# news_absent.R

# init ----
library(dplyr)
load("newsdaily.RData")
thenews <- c("agendadaily",
             "airtimes",
             "astroawani",
             "beritaharian",
             "bernama",
             "borneopost",
             "dailyexpress",
             "fmt",
             "FinanceTwitter",
             "harakahdaily",
             "hmetro",
             "kosmo",
             "malaysiadateline",
             "malaysiachronicle",
             "malaysiakini",
             "malaysianow",
             "malaysiainsight",
             "newsarawaktribune",
             "nst",
             "roketkini",
             "sarawakvoice",
             "sinarharian",
             "theAseanPost",
             "theedge",
             "themalaymailonline",
             "theRakyatPost",
             "thesundaily",
             "thestar",
             "umnoonline",
             "utusan")

# compare ----
df <- tibble::tibble(thenews)
df %>% left_join(news.today, by=c("thenews" = "src")) %>%
  filter(is.na(datePub)) %>% 
  View()

