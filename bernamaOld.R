# bernama.R

# Init --------------------------------------------------------------------

library(rvest)
library(dplyr)

# Read html ---------------------------------------------------------------

theNews <- read_html("https://www.bernama.com/bm/am/")

headlines <- theNews %>%
  html_nodes("h6 a.text-dark.text-decoration-none") %>%
  html_text()

newslink <- theNews %>%
  html_nodes("h6 a.text-dark.text-decoration-none") %>%
  html_attr("href")

# Verify link -------------------------------------------------------------

fol.up <- TRUE
maxpage <- 5
no.links <- length(headlines)
article <- matrix("", no.links*maxpage)
datePub <- format(Sys.Date(), "%d %b %Y")
src <- matrix("bernama",no.links*maxpage)
datePub <- matrix(datePub,no.links*maxpage)
newstitles <- matrix("",no.links,maxpage)
newsurl <- matrix("",no.links,maxpage)

# First page --------------------------------------------------------------

for (j in (1:no.links)) {
  if (headlines[j] != "")
    newstitles[j, 1] <- headlines[j]
}

for (j in (1:no.links)){
  if (!grepl("watch",newslink[j]) & j<13)
    newsurl[j,1] <- paste0("https://www.bernama.com/bm/am/",newslink[j])
  else
    newsurl[j,1] <- newslink[j] 
}

# Follow link -------------------------------------------------------------

if (fol.up){
  for(i in 2:maxpage) {
    
    theNews <- read_html(paste0("https://www.bernama.com/bm/am/index.php?page=",i))
    
    try(headlines <- theNews %>%
      html_nodes("h6 a.text-dark.text-decoration-none") %>%
      html_text(), silent=T)
    
    for (j in (1:no.links)) {
      try(if (headlines[j] != "")
        newstitles[j, i] <- headlines[j], silent = T)
    }
    
    newslink <- theNews %>%
      html_nodes("h6 a.text-dark.text-decoration-none") %>%
      html_attr("href")
    
    for (j in (1:no.links)){
      if (!grepl("watch",newslink[j]))
        newsurl[j,i] <- paste0("https://www.bernama.com/bm/am/",newslink[j])
      else
        newsurl[j,i] <- newslink[j]
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
  txt <- ""
  try(txt <- read_html(newslink[i]) %>%
        html_nodes("p") %>%
        html_text(), silent=TRUE)
  txt <- gsub('\\n', ' ', txt)
  txt <- paste(txt, collapse = ' ')
  article[i] <- txt
  j <- j + 1
  Sys.sleep(3)
  # update progress bar
  setTxtProgressBar(pb, j)
}
Sys.sleep(1)
close(pb)
bernama.df <- data.frame(src, datePub, headlines, newslink, article)
