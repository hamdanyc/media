# beritaharian.R

# Init --------------------------------------------------------------------

library(rvest)
library(dplyr)

# Read html ---------------------------------------------------------------

theNews <- read_html("https://www.bharian.com.my/berita/nasional")

headlines <- theNews %>%
  html_nodes("a.d-flex.article.listing.mb-3.pb-3 h6.field-title") %>%
  html_text()

newslink <- theNews %>%
  html_nodes("a.d-flex.article.listing.mb-3.pb-3") %>%
  html_attr("href")

newslink <- paste0("https://www.bharian.com.my", newslink)

# Verify link -------------------------------------------------------------

# # remove blank headlines
# headlines <- headlines[-which(headlines=="")]

fol.up <- FALSE
maxpage <- 1
no.links <- length(headlines)
article <- matrix("", no.links*maxpage)
datePub <- format(Sys.Date(), "%d %b %Y")
src <- matrix("beritaharian",no.links*maxpage)
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
  for(i in 1:maxpage) {
    
    theNews <- read_html(paste0("https://www.bharian.com.my/berita/nasional?page=", i))
    
    headlines <- theNews %>%
      html_nodes("span.field-content a") %>%
      html_text()
    
    for (j in (1:no.links)) {
      try(if (headlines[j] != "")
        newstitles[j, i] <- headlines[j], silent = T)
    }
    
    newslink <- theNews %>%
      html_nodes("span.field-content a") %>%
      html_attr("href")
    
    for (j in (1:no.links)){
      try(if (newslink[j] != "")
        newsurl[j,i] <- paste0("https://www.bharian.com.my",newslink[j]), silent = T)
    }
    
  }
}

# theNews %>%
#   html_nodes(".pager-next a") %>%
#   html_attrs()

# Scrape page -------------------------------------------------------------

newslink <- as.character(newsurl)
headlines <- as.character(newstitles)
j <- 0
# create progress bar
pb <- txtProgressBar(min = 0, max = maxpage*no.links, style = 3)

for (i in 1:length(newslink)) {
  try(txt <- read_html(newslink[i]) %>%
    html_nodes(".field-items p") %>%
    html_text(), silent = TRUE)
  txt <- gsub('\\n', ' ', txt)
  txt <- paste(txt, collapse = ' ')
  article[i] <- txt
  j <- j + 1
  Sys.sleep(3.5)
  # update progress bar
  setTxtProgressBar(pb, j)
}
Sys.sleep(1)
close(pb)
news.csv <- data.frame(src, datePub, headlines, newslink, article)
beritaharian.df <- news.csv