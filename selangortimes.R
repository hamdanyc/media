# selangortimes.R

# Init --------------------------------------------------------------------

library(rvest)
library(dplyr)

# Read html ---------------------------------------------------------------

theNews <- read_html("http://www.selangortimes.com/index.php?section=news")

headlines <- theNews %>%
  html_nodes(".main_news_desc > .space+ p .current_news_title") %>%
  html_text()

newslink <- theNews %>%
  html_nodes(".main_news_desc > .space+ p .current_news_title") %>%
  html_attr("href")

# newslink <- paste0("http://www.bharian.com.my", newslink)

# Verify link -------------------------------------------------------------

# # remove blank headlines
# headlines <- headlines[-which(headlines=="")]

fol.up <- TRUE
maxpage <- 5
no.links <- length(headlines)
article <- matrix("", no.links*maxpage)
datePub <- format(Sys.Date(), "%d %b %Y")
src <- matrix("selangortimes",no.links*maxpage)
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
    newsurl[j,1] <- paste0("http://www.selangortimes.com/",newslink[j])
}

# Follow link -------------------------------------------------------------
k <- 0
if (fol.up){
  for(i in 2:maxpage) {
    
    k <- k + 15
    theNews <- read_html(paste0("http://www.selangortimes.com/index.php?section=news&search=&offset=", k))
    
    headlines <- theNews %>%
      html_nodes(".main_news_desc > .space+ p .current_news_title") %>%
      html_text()
    
    for (j in (1:no.links)) {
      try(if (headlines[j] != "")
        newstitles[j, i] <- headlines[j], silent = T)
    }
    
    newslink <- theNews %>%
      html_nodes(".main_news_desc > .space+ p .current_news_title") %>%
      html_attr("href")
    
    for (j in (1:no.links)){
      try(if (newslink[j] != "")
        newsurl[j,i] <- paste0("http://www.selangortimes.com/",newslink[j]), silent = T)
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
  try(txt <- read_html(newslink[i]) %>%
    html_nodes(".contentdetails p") %>%
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
selangortimes.df <- news.csv