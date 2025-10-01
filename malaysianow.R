# malaysianow.R

# Init ----
library(rvest)
library(dplyr)

# Read html ----
theNews <- read_html("https://www.malaysianow.com/section/news/")

headlines <- theNews %>%
  html_nodes("a.mt-2.block") %>%
  html_text()

newslink <- theNews %>%
  html_nodes("a.mt-2.block") %>%
  html_attr("href")

# set var
headlines <- tibble("headlines"=unlist(headlines)) %>% 
  distinct()
newslink <- tibble("newslink"=unlist(newslink))%>% 
  distinct()
n <- nrow(headlines)
article <- ""
datePub <- replicate(n,format(Sys.Date(), "%Y/%m/%d"))
src <- replicate(n,"malaysianow")

# Scrape page ----
j <- 0
error <- FALSE

# create progress bar
pb <- txtProgressBar(min = 0, max = n, style = 3)
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
malaysianow.df <- tibble(src, datePub, headlines, newslink, article)

# calc sentiment & insert db ----
df <- malaysianow.df
# if(batch) source("call_sentmnt.R")
