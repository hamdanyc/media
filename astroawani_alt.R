# astroawani.R

# init ----
library(RSelenium)
library(rvest)
library(dplyr)

# start a chrome browser
rD <- remoteDriver(browserName = "phantomjs")
rD$open()
# rD <- rsDriver(browser = c("firefox"))
remDr <- rD[["client"]]
remDr$getStatus() # check server status

# Read html ----
theNews <- "https://www.astroawani.com/berita-malaysia"
remDr$navigate(theNews)

headlines <- theNews %>%
  html_nodes("div.css-1shzhes") %>%
  html_text() 

newslink <- theNews %>% # no link only short text
  html_nodes("div.css-1b4bwu4") %>%
  html_text()

# Verify link -------------------------------------------------------------

fol.up <- TRUE
maxpage <- 3
no.links <- length(headlines)
article <- matrix("", no.links*maxpage)
datePub <- format(Sys.Date(), "%d %b %Y")
src <- matrix("astroawani",no.links*maxpage)
datePub <- matrix(datePub,no.links*maxpage)
newstitles <- matrix("",no.links,maxpage)
newsurl <- matrix("",no.links,maxpage)

# First page --------------------------------------------------------------

for (j in (1:no.links)) {
  if (headlines[j] != "")
    newstitles[j, 1] <- headlines[j]
}

for (j in (1:no.links)){
  if (newslink[j] != "")
    newsurl[j,1] <- newslink[j]
}

# Follow link -------------------------------------------------------------

if (fol.up){
  for(i in 2:maxpage) {
    
    theNews <- read_html(paste0("http://www.astroawani.com/berita-malaysia/terkini/",i,"/q/%2Fberita-malaysia"))
    
    headlines <- theNews %>%
      html_nodes(".listing-title") %>%
      html_text()
    
    for (j in (1:no.links)) {
      try(if (headlines[j] != "")
        newstitles[j, i] <- headlines[j], silent = T)
    }
    
    newslink <- theNews %>%
      html_nodes(".listing-title") %>%
      html_attr("href")
    
    for (j in (1:no.links)){
      try(if (newslink[j] != "")
        newsurl[j,i] <- newslink[j], silent = T)
    }
    
  }
}

# Scrape page -------------------------------------------------------------

newslink <- as.character(newsurl)
headlines <- as.character(newstitles)
j <- 0
# create progress bar
pb <- txtProgressBar(min = 0, max = maxpage*no.links, style = 3)

for (i in 1:length(newslink)) {
  if (newslink[i] == "") next
  try(txt <- read_html(newslink[i]) %>%
    html_nodes(".detail-body-content") %>%
    html_text(), silent = TRUE)
  txt <- gsub('\\n', ' ', txt)
  txt <- paste(txt, collapse = ' ')
  article[i] <- txt
  j <- j + 1
  Sys.sleep(0.1)
  # update progress bar
  setTxtProgressBar(pb, j)
}
Sys.sleep(1)
close(pb)
news.csv <- data.frame(src, datePub, headlines, newslink, article)
astroawani.df <- news.csv
