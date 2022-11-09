# agendadaily.R

# Init ----
library(rvest)
library(dplyr)

# get news info ----
# get url 
remDr$navigate(url = "https://www.agendadaily.com/politik/")
Sys.sleep(3)
headlines <- xml2::read_html(remDr$getPageSource()[[1]]) %>%
  rvest::html_elements("div.unit.post") %>%
  rvest::html_text2()

newslink <- xml2::read_html(remDr$getPageSource()[[1]]) %>%
  html_nodes(".hl") %>%
  html_attr("href")

# set page attrib ----
n <- length(headlines)
datePub <- format(Sys.Date(),"%Y/%m/%d")
src <- replicate(n,"agendadaily")
datePub <- replicate(n,datePub)
error <- FALSE

# Scrape page ----
# create progress bar
article <- ""
j <- 0
pb <- txtProgressBar(min = 0, max = n, style = 3)
for (i in 1:n) {
  txt <- ""
  remDr$navigate(newslink[i])
  Sys.sleep(2)
  tryCatch(txt <- xml2::read_html(remDr$getPageSource()[[1]]) %>%
             rvest::html_elements("p") %>%
             rvest::html_text2(), error = function(e) e)
  if(error) break
  txt <- paste(txt, collapse = ' ')
  article[i] <- txt
  j <- j + 1
  # update progress bar
  setTxtProgressBar(pb, j)
}
Sys.sleep(1)
close(pb)

# create data frame
agendadaily.df <- tibble(src, datePub, headlines, newslink, article)

# calc sentiment & insert db ----
df <- agendadaily.df
if(batch) source("call_sentmnt.R")
