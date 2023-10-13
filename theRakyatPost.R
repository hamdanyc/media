# theRakyatPost.R

# Init ----
library(rvest)
library(dplyr)

# Read html ----
theNews <- read_html("https://www.therakyatpost.com/category/news/")

headlines <- theNews %>%
  html_nodes("div.post h5") %>%
  html_text2()

newslink <- theNews %>%
  html_nodes("div.post h5 a") %>%
  html_attr("href")

# set var
headlines <- unlist(headlines)
newslink <- unlist(newslink)
no.links <- length(newslink)
article <- ""
datePub <- replicate(no.links,format(Sys.Date(), "%Y/%m/%d"))
src <- replicate(no.links,"therakyatpost")

# Scrape page ----
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
therakyatpost.df <- tibble(src, datePub, headlines, newslink, article)

# calc sentiment & insert db ----
df <- therakyatpost.df
# if(batch) source("call_sentmnt.R")
