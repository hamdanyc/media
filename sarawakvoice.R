# sarawakvoice.R

# Init ----
library(rvest)
library(dplyr)

# Read html ----
theNews <- read_html("https://sarawakvoice.com/")

headlines <- theNews %>%
  html_nodes(".entry-title.td-module-title") %>%
  html_text2()

newslink <- theNews %>%
  html_nodes(".entry-title.td-module-title a") %>%
  html_attr("href")

# set var
headlines <- tibble("headlines"=unlist(headlines))
newslink <- tibble("newslink"=unlist(newslink))
no.links <- nrow(headlines)
datePub <- replicate(no.links,format(Sys.Date(), "%Y/%m/%d"))
src <- replicate(no.links,"sarawakvoice")

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
sarawakvoice.df <- tibble(src, datePub, headlines, newslink, article)

# calc sentiment & insert db ----
df <- sarawakvoice.df
if(batch) source("call_sentmnt.R")