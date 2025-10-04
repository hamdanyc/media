# zmy.R

# Init --------------------------------------------------------------------

library(rvest)
library(dplyr)

# Read html ---------------------------------------------------------------

theNews <- read_html("https://zaharinmy.blogspot.com/")

headlines <- theNews %>%
  html_nodes("li.archivedate a") %>%
  html_text()

newslink <- theNews %>%
  html_nodes("li.archivedate a") %>%
  html_attr("href")

# Verify link -------------------------------------------------------------

maxpage <- 1
no.links <- length(headlines)
article <- matrix("", no.links*maxpage)
datePub <- format(Sys.Date(), "%d %b %Y")
src <- matrix("zmy",no.links*maxpage)
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
    newsurl[j,1] <- paste0(newslink[j])
}

# Follow link -------------------------------------------------------------
# https://www.malaysiachronicle.com/c/my/news/6d9a29e6f24544e92a8b92d6fcc845d6
# 
# for(i in 2:maxpage) {
#   
#   try(theNews <- read_html("https://www.malaysiachronicle.com/c/my/news"),
#       silent = T)
#   
#   headlines <- theNews %>%
#     html_nodes(".uk-grid-width-large-1-4 li") %>%
#     html_text()
#   
#   for (j in (1:length(headlines))) {
#     try(if (headlines[j] != "")
#       newstitles[j, i] <- headlines[j], silent = T)
#   }
#   
#   newslink <- theNews %>%
#     html_nodes(".uk-position-cover") %>%
#     html_attr("href")
#   
#   for (j in (1:length(headlines))){
#     try(if (newslink[j] != "")
#       newsurl[j,i] <- paste0("https://www.malaysiachronicle.com",newslink[j]),
#       silent = T)
#   }
#   
# }

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
zmy.df <- data.frame(src, datePub, headlines, newslink, article)