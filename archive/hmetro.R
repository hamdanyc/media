# hmetro.R

# Init --------------------------------------------------------------------

library(rvest)
library(dplyr)

# get news info ----
# get url 
remDr$navigate(url = "https://www.hmetro.com.my/")
Sys.sleep(3)
headlines <- xml2::read_html(remDr$getPageSource()[[1]]) %>%
  rvest::html_elements("a.mb-3.col-6 .field-title.mt-1") %>%
  rvest::html_text2()

newslink <- xml2::read_html(remDr$getPageSource()[[1]]) %>%
  html_nodes("a.mb-3.col-6") %>%
  html_attr("href")

# set page attrib ----
newslink <- paste0("https://www.hmetro.com.my", newslink)
n <- length(headlines)
datePub <- format(Sys.Date(),"%Y/%m/%d")
src <- replicate(n,"hmetro")
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
hmetro.df <- tibble(src, datePub, headlines, newslink, article)

# calc sentiment & insert db ----
df <- hmetro.df
# if(batch) source("call_sentmnt.R")

