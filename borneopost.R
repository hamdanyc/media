# borneopost.R

# Init ----
library(rvest)
library(dplyr)

# Read html ----
# https://www.theborneopost.com/category/news/nation/page/2/
maxpage <- 5
headlines <- lapply(1:maxpage, function(i) {
  Sys.sleep(1)
  theNews <- read_html(paste0("https://www.theborneopost.com/category/news/nation/page/",i,"/")) %>% 
  html_nodes("a.post-title") %>%
  html_text2()
})

newslink <- lapply(1:maxpage, function(i) {
  Sys.sleep(1)
  theNews <- read_html(paste0("https://www.theborneopost.com/category/news/nation/page/",i,"/")) %>% 
  html_nodes("a.post-title") %>%
  html_attr("href")
})

headlines <- tibble("headlines"=unlist(headlines))
newslink <- tibble("newslink"=unlist(newslink))
no.links <- nrow(headlines)
datePub <- replicate(no.links,format(Sys.Date(), "%Y/%m/%d"))
src <- replicate(no.links,"borneopost")

# Scrape page ----
j <- 0
error <- FALSE
article <- ""
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
borneopost.df <- tibble(src, datePub, headlines, newslink, article)

# calc sentiment & insert db ----
df <- borneopost.df
# if(batch) source("call_sentmnt.R")
