# theAseanPost.R

# Init ----
library(rvest)
library(dplyr)

# Read html ---- https://theaseanpost.com/views/ajax?page=2
theNews <- read_html("https://theaseanpost.com/geopolitics")

headlines <- theNews %>%
  html_nodes("h3.post-title") %>%
  html_text2()

newslink <- theNews %>%
  html_nodes("h3.post-title a") %>%
  html_attr("href")

# set var
url <- "https://theaseanpost.com"
newslink <- paste0(url,newslink)
no.links <- length(headlines)
datePub <- replicate(no.links,format(Sys.Date(), "%Y/%m/%d"))
src <- replicate(no.links,"theAseanPost")

# Scrape page ----
article <- ""
j <- 0
error <- FALSE

# create progress bar
pb <- txtProgressBar(min = 0, max = no.links, style = 3)
for(i in 1:no.links){
  Sys.sleep(0.7)
  txt <- ""
  tryCatch(txt <- read_html(newslink[i]) %>%
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
theAseanPost.df <- tibble(src, datePub, headlines, newslink, article)

# calc sentiment & insert db ----
df <- theAseanPost.df
if(batch) source("call_sentmnt.R")
