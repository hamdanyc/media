# malaysiadateline.R

# Init ----
library(rvest)
library(dplyr)

# Read html ----
maxpage <- 5
headlines <- lapply(1:maxpage, function(i) {
  Sys.sleep(1)
  theNews <- read_html(paste0("https://malaysiadateline.com/category/berita/page/",i,"/")) %>% 
    html_elements(".entry-title a") %>% 
    html_text2()
})

newslink <- lapply(1:maxpage, function(i) {
  Sys.sleep(1)
  theNews <- read_html(paste0("https://malaysiadateline.com/category/berita/page/",i,"/"))
  theNews %>%
    html_elements(".entry-title a") %>%
    html_attr("href")
})
# set var
headlines <- tibble("headlines"=unlist(headlines)) %>% 
  distinct()
newslink <- tibble("newslink"=unlist(newslink))%>% 
  distinct()
no.links <- nrow(headlines)
article <- ""
datePub <- replicate(no.links,format(Sys.Date(), "%Y/%m/%d"))
src <- replicate(no.links,"malaysiadateline")

# Scrape page ----
j <- 0
error <- FALSE

# create progress bar
pb <- txtProgressBar(min = 0, max = no.links, style = 3)
for(i in 1:nrow(newslink)){
  Sys.sleep(0.7)
  txt <- ""
  tryCatch(txt <- read_html(newslink$newslink[i]) %>%
             html_nodes(".entry-content.clear p") %>%
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
malaysiadateline.df <- tibble(src, datePub, headlines, newslink, article)

# calc sentiment & insert db ----
df <- malaysiadateline.df
# if(batch) source("call_sentmnt.R")
