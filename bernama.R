# bernama.R

# Init ----
library(rvest)
library(dplyr)

# Read html ----
maxpage <- 3
headlines <- lapply(1:maxpage, function(i) {
  Sys.sleep(1)
  theNews <- read_html(paste0("https://www.bernama.com/bm/am/index.php?page=",i)) %>% 
    html_elements("h6 .text-dark.text-decoration-none") %>% 
    html_text()
})

newslink <- lapply(1:maxpage, function(i) {
  Sys.sleep(1)
  theNews <- read_html(paste0("https://www.bernama.com/bm/am/index.php?page=",i))
  theNews %>%
    html_elements("h6 .text-dark.text-decoration-none") %>%
    html_attr("href")
})

# set var
url <- "https://www.bernama.com/bm/am/"
headlines <- tibble("headlines"=unlist(headlines)) %>% 
  distinct()
newslink <- tibble("newslink"=unlist(newslink)) %>%
  distinct()
newslink <- if_else(stringr::str_detect(newslink$newslink,"http"),newslink$newslink,paste0(url,newslink$newslink))
no.links <- nrow(headlines)
article <- ""
datePub <- replicate(no.links,format(Sys.Date(), "%Y/%m/%d"))
src <- replicate(no.links,"bernama")

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
bernama.df <- tibble(src, datePub, headlines, newslink, article) %>% 
  mutate(article = if_else(article == "",headlines,article))

# calc sentiment & insert db ----
df <- bernama.df
if(batch) source("call_sentmnt.R")
bernama.df <- df
