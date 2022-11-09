# umnoonline.R

# Init ----
library(rvest)
library(dplyr)

# Read html ----https://umno-online.my/berita/utama/page/2/
maxpage <- 3
headlines <- lapply(1:maxpage, function(i) {
  Sys.sleep(1)
  read_html(paste0("https://umno-online.my/berita/utama/page/",i,"/")) %>% 
  html_nodes(".post-title") %>%
  html_text2()
})


newslink <- lapply(1:maxpage, function(i) {
  Sys.sleep(1)
  read_html(paste0("https://umno-online.my/berita/utama/page/",i,"/")) %>% 
  html_nodes(".more-link") %>%
  html_attr("href")
})

# set var
headlines <- unlist(headlines)
newslink <- unlist(newslink)
no.links <- length(newslink)
article <- ""
datePub <- replicate(no.links,format(Sys.Date(), "%Y/%m/%d"))
src <- replicate(no.links,"umnoonline")

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
umnoonline.df <- tibble(src, datePub, headlines, newslink, article)

# calc sentiment & insert db ----
df <- umnoonline.df
if(batch) source("call_sentmnt.R")
