# FinanceTwitter.R

# Init ----
library(rvest)
library(dplyr)

# Read html ----
theNews <- read_html("http://www.financetwitter.com/")

headlines <- theNews %>%
  html_nodes("div.post h1") %>%
  html_text()

newslink <- theNews %>%
  html_nodes("div.post h1 a") %>%
  html_attr("href")

# set var
headlines <- tibble("headlines"=unlist(headlines))
newslink <- tibble("newslink"=unlist(newslink))
no.links <- nrow(headlines)
datePub <- replicate(no.links,format(Sys.Date(), "%Y/%m/%d"))
src <- replicate(no.links,"financetwitter")

# Scrape page ----
article <- ""
j <- 0
error <- FALSE

# create progress bar
pb <- txtProgressBar(min = 0, max = no.links, style = 3)
for(i in 1:nrow(newslink)){
  Sys.sleep(0.7)
  txt <- ""
  tryCatch(txt <- read_html(newslink$newslink[i]) %>%
             html_nodes("p") %>%
             html_text2(),error = function(e) e)
  if(error) break
  txt <- gsub('\\n', ' ', txt)
  txt <- paste(txt, collapse = ' ')
  article[i] = txt
  j <- j + 1
  # update progress bar
  setTxtProgressBar(pb, j)
}

Sys.sleep(1)
close(pb)
financetwitter.df <- tibble(src, datePub, headlines, newslink, article)

# calc sentiment & insert db ----
df <- financetwitter.df
# if(batch) source("call_sentmnt.R")
