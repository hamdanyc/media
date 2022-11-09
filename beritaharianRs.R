# beritaharian.R

# init -----
library(dplyr)

# server
remDr <- RSelenium::remoteDriver(remoteServerAddr = "192.168.1.116",
                                 port = 4444L,
                                 browserName = "firefox")

remDr$open()

# get news info ----
# get url 
remDr$navigate(url = "https://www.bharian.com.my/berita/nasional/") # Entering our URL
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
newslink <- paste0("https://www.bharian.com.my", newslink)

# for(i in 1:2){
#   Sys.sleep(0.7)

  
  # next page
  # df <- dplyr::tibble(headlines,newslink) 
  # news <- bind_rows(news,df)
  # clickElem <- remDr$findElement(using = "css", "[class = 'page-link']")
  # Sys.sleep(2)
  # clickElem$clickElement()
  # Sys.sleep(2)
# }

# set page attrib ----
n <- length(headlines)
datePub <- format(Sys.Date(), "%d %b %Y")
src <- replicate(n,"Berita Harian")
datePub <- replicate(n,datePub)
error <- FALSE
article <- ""

# Scrape page ----
# create progress bar
j <- 0
pb <- txtProgressBar(min = 0, max = n, style = 3)
for (i in 1:n) {
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
beritaharian.df <- tibble(src, datePub, headlines, newslink, article)

# close ----
remDr$close()
remDr$closeServer()
