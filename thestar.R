# thestar.R

# Init ----
library(rvest)
library(dplyr)

# get news info ----
# get url 
remDr$navigate(url = "https://www.thestar.com.my/news/nation") # Entering our URL
df <- ""
news <- list(headlines="",newslink="")
Sys.sleep(3)
headlines <- xml2::read_html(remDr$getPageSource()[[1]]) %>%
  rvest::html_elements(".f18 a") %>%
  rvest::html_text2()
Sys.sleep(3)
newslink <- xml2::read_html(remDr$getPageSource()[[1]]) %>%
  rvest::html_elements(".f18 a") %>%
  rvest::html_attr("href")

# set page attrib ----
url <- "https://www.thestar.com.my"
newslink <- if_else(stringr::str_detect(newslink,"http"),newslink,paste0(url,newslink))
n <- length(newslink)
datePub <- format(Sys.Date(),"%Y/%m/%d")
src <- replicate(n,"thestar")
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
  tryCatch(txt <- xml2::read_html(remDr$getPageSource()[[1]]) %>%
             rvest::html_elements("p") %>%
             rvest::html_text2(), error = function(e) e)
  if(error) break
  txt <- paste(txt, collapse = ' ')
  article[i] <- txt
  j <- j + 1
  Sys.sleep(2)
  # update progress bar
  setTxtProgressBar(pb, j)
}
Sys.sleep(1)
close(pb)
thestar.df <- tibble(src, datePub, headlines, newslink, article)