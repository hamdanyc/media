# theedge.R

# Init ----
library(rvest)
library(dplyr)

# Read html ---- https://www.theedgemarkets.com/categories/malaysia?page=1
maxpage <- 3

headlines <- lapply(1:maxpage, function(i) {
  Sys.sleep(1)
  read_html(paste0("https://www.theedgemarkets.com/categories/malaysia?page=",i)) %>% 
  html_nodes(".views-field-title a") %>%
  html_text2()
})

newslink <- lapply(1:maxpage, function(i) {
  Sys.sleep(1)
  read_html(paste0("https://www.theedgemarkets.com/categories/malaysia?page=",i)) %>% 
  html_nodes(".views-field-title a") %>%
  html_attr("href")
})

# set var
url <- "https://www.theedgemarkets.com"
headlines <- unlist(headlines)
newslink <- unlist(newslink)
newslink <- paste0(url,newslink)
no.links <- length(newslink)
article <- ""
datePub <- replicate(no.links,format(Sys.Date(), "%Y/%m/%d"))
src <- replicate(no.links,"theedge")

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
theedge.df <- tibble(src, datePub, headlines, newslink, article)

# calc sentiment & insert db ----
df <- theedge.df
if(batch) source("call_sentmnt.R")
