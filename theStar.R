# thestar.R

# Init --------------------------------------------------------------------

library(rvest)
library(dplyr)

# Read html ---------------------------------------------------------------

theNews <- read_html("https://www.thestar.com.my/news/nation")
# ss <- html_session("http://www.thestar.com.my/news/nation")

headlines <- theNews %>%
  html_nodes(".f18") %>%
  html_text()

newslink <- theNews %>%
  html_nodes(".f18 a") %>%
  html_attr("href")

# Verify link -------------------------------------------------------------

# # remove blank headlines
# headlines <- headlines[-which(headlines=="")]

maxpage <- 3
no.links <- length(headlines)
article <- matrix("", no.links*maxpage)
datePub <- format(Sys.Date(), "%d %b %Y")
src <- matrix("thestar",no.links*maxpage)
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
    newsurl[j,1] <- paste0("http://www.thestar.com.my", newslink[j])
}

# Follow link -------------------------------------------------------------

for(i in 2:maxpage) {
  
  try(theNews <- read_html(paste0("http://www.thestar.com.my/news/nation/?pgno=",i,"#Nation")),
      silent = T)
  
  headlines <- theNews %>%
    html_nodes(".f18") %>%
    html_text()
  
  for (j in (1:no.links)) {
    try(if (headlines[j] != "")
      newstitles[j, i] <- headlines[j], silent=TRUE)
  }
  
  newslink <- theNews %>%
    html_nodes(".f18 a") %>%
    html_attr("href")
  
  for (j in (1:no.links)){
    try(if (newslink[j] != "")
      newsurl[j,i] <- paste0("http://www.thestar.com.my",newslink[j]),
          silent=TRUE)
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
        html_nodes("#story-body p") %>%
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
thestar.df <- data.frame(src, datePub, headlines, newslink, article)