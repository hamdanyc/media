# kosmo.R

# Init ----

library(rvest)
library(dplyr)

# Read html ----
theNews <- read_html("http://www.kosmo.com.my/negara")

headlines <- theNews %>%
  html_elements(".jeg_post_title") %>%
  html_text()

newslink <- theNews %>%
  html_elements(".jeg_post_title a") %>%
  html_attr("href")

# set var
headlines <- tibble("headlines"=unlist(headlines)) %>% 
  distinct()
newslink <- tibble("newslink"=unlist(newslink))%>% 
  distinct()
n <- nrow(headlines)
article <- ""
datePub <- replicate(n,format(Sys.Date(), "%Y/%m/%d"))
src <- replicate(n,"kosmo")

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
kosmo.df <- tibble(src, datePub, headlines, newslink, article)

# calc sentiment & insert db ----
df <- kosmo.df
if(batch) source("call_sentmnt.R")
