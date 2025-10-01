# dailyexpress.R

# Init ----
library(rvest)
library(dplyr)

# Read html ----
theNews <- read_html("http://www.dailyexpress.com.my/sarawak/")

headlines <- theNews %>%
  html_nodes(".title a") %>%
  html_text2()

newslink <- theNews %>%
  html_nodes(".title a") %>%
  html_attr("href")

# set var
headlines <- tibble("headlines"=unlist(headlines))
newslink <- tibble("newslink"=unlist(newslink))
no.links <- nrow(headlines)
datePub <- replicate(no.links,format(Sys.Date(), "%Y/%m/%d"))
src <- replicate(no.links,"dailyexpress")
newslink <- paste0("http://www.dailyexpress.com.my",newslink$newslink)
article <- ""

# Scrape page ----
j <- 0
# create progress bar
pb <- txtProgressBar(min = 0, max = no.links, style = 3)

for (i in 1:length(newslink)) {
  if (newslink[i] == "") next
  try(txt <- read_html(newslink[i]) %>%
        html_nodes(".headlines , p") %>%
        html_text2(), silent=TRUE)
  txt <- gsub('\\n', ' ', txt)
  txt <- paste(txt, collapse = ' ')
  article[i] <- txt
  j <- j + 1
  Sys.sleep(0.1)
  # update progress bar
  setTxtProgressBar(pb, j)
}
Sys.sleep(1)
close(pb)
dailyexpress.df <- tibble(src, datePub, headlines, newslink, article)

# calc sentiment & insert db ----
df <- dailyexpress.df
# if(batch) source("call_sentmnt.R")
