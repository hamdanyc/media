# sinchew.R

# Init --------------------------------------------------------------------

library(rvest)
library(dplyr)

# Read html ---------------------------------------------------------------

theNews <- read_html("https://mysinchew.sinchew.com.my/")

headlines <- theNews %>%
  html_nodes("#title") %>%
  html_text()

newslink <- theNews %>%
  html_nodes("#title") %>%
  html_attr("href")

# Verify link -------------------------------------------------------------

maxpage <- 2
no.links <- length(headlines)
article <- matrix("", no.links*maxpage)
datePub <- format(Sys.Date(), "%d %b %Y")
src <- matrix("sinchew",no.links*maxpage)
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
    newsurl[j,1] <- paste0("http://www.mysinchew.com", newslink[j])
}

# Follow link -------------------------------------------------------------

try(
  for(i in 2:maxpage) {

    theNews <- read_html(paste0("http://www.mysinchew.com/taxonomy/term/47?page=",i,".html"))

    headlines <- theNews %>%
      html_nodes("#title") %>%
      html_text()

    try(
    for (j in (1:no.links)) {
      if (headlines[j] != "")
        newstitles[j, i] <- headlines[j]
    })

    newslink <- theNews %>%
      html_nodes("#title") %>%
      html_attr("href")

    try(
    for (j in (1:no.links)){
      if (newslink[j] != "")
        newsurl[j,i] <- paste0("http://www.mysinchew.com", newslink[j])
    })

  })

# Scrape page -------------------------------------------------------------

newslink <- as.character(newsurl)
headlines <- as.character(newstitles)
j <- 0
# create progress bar
pb <- txtProgressBar(min = 0, max = maxpage*no.links, style = 3)

for (i in 1:length(newslink)) {
  if (newslink[i] == "") next
  try(txt <- read_html(newslink[i]) %>%
        html_nodes("p") %>%
        html_text(), silent=TRUE)
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
sinchew.df <- data.frame(src, datePub, headlines, newslink, article)
