# nst.R

# Init ----
library(rvest)
library(dplyr)

# get news info ----
# get url 
remDr$navigate(url = "https://www.nst.com.my/news/nation/") # Entering our URL
df <- ""
news <- list(headlines="",newslink="")
Sys.sleep(3)
headlines <- xml2::read_html(remDr$getPageSource()[[1]]) %>%
  rvest::html_elements("h6.field-title") %>%
  rvest::html_text()
Sys.sleep(3)
newslink <- xml2::read_html(remDr$getPageSource()[[1]]) %>%
  rvest::html_elements("a.d-flex.article.listing.mb-3.pb-3") %>%
  rvest::html_attr("href")
newslink <- paste0("https://www.nst.com.my", newslink)

# set page attrib ----
n <- length(headlines)
datePub <- format(Sys.Date(),"%Y/%m/%d")
src <- replicate(n,"nst")
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

# create data frame
nst.df <- tibble(src, datePub, headlines, newslink, article)
