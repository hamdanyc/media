# hansard.R

# Init --------------------------------------------------------------------

library(rvest)
library(dplyr)

# Read html ---------------------------------------------------------------
url <- "https://www.parlimen.gov.my/carian.html?str=aset+pertahanan&DATETYPE=0&daterangeraw=09%2F09%2F2022+-+08%2F10%2F2022&ruustr=&str2=&submit=CARI&doctype%5B%5D=DN-hs&dokumen%5B%5D=perbahasan&searchref=hansard-dewan-negara&searchrefcode=dn"
fol_url <- paste("https://www.parlimen.gov.my/carian.html?page=",i,"&ipp=30&documen%5B%5D=perbahasan&doctype%5B%5D=DN-hs&daterangeraw=09%2F09%2F2022+-+08%2F10%2F2022&DATETYPE=0&str2=&str=aset+pertahanan&uweb=dn&submit=CARI")
theNews <- read_html(url)

headlines <- theNews %>%
  html_nodes("h3 a") %>%
  html_text()

newslink <- theNews %>%
  html_nodes("h3 a") %>%
  html_attr("href")

# Verify link -------------------------------------------------------------

# # remove blank headlines
# headlines <- headlines[-which(headlines=="")]

maxpage <- 30
no.links <- length(headlines)
article <- matrix("", no.links*maxpage)
datePub <- format(Sys.Date(), "%d %b %Y")
src <- matrix("hansard",no.links*maxpage)
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
    newsurl[j,1] <- paste0("https://www.parlimen.gov.my",newslink[j])
}

# Follow link -------------------------------------------------------------

# k <- 10
for(i in 2:maxpage) {
  
  try(theNews <- read_html(paste0(url)),
      silent = T)
  # https://www.parlimen.gov.my/carian.html?page=i&ipp=30&str=anggota+tentera+bukan+bumiputera&DATETYPE=0&daterangeraw=14%2F03%2F2022+-+12%2F04%2F2022&ruustr=&str2=&submit=CARI&doctype%5B%5D=DR-hs&dokumen%5B%5D=perbahasan&searchref=hansard-dewan-rakyat&searchrefcode=dr
  headlines <- theNews %>%
    html_nodes("h3 a") %>%
    html_text()
  
  for (j in (1:no.links)) {
    try(if (headlines[j] != "")
      newstitles[j, i] <- headlines[j], silent = T)
  }
  
  newslink <- theNews %>%
    html_nodes("h3 a") %>%
    html_attr("href")
  
  for (j in (1:no.links)){
    try(if (newslink[j] != "")
      newsurl[j,i] <- paste0("https://www.parlimen.gov.my",newslink[j]), silent = T)
  }
  
  # k <- k + 10
  
}

# Scrape page -------------------------------------------------------------

newslink <- as.character(newsurl)
headlines <- as.character(newstitles)
j <- 0
# create progress bar
pb <- txtProgressBar(min = 0, max = maxpage*no.links, style = 3)

for (i in 1:length(newslink)) {
  # if (newslink[i] == "") next
  # try(txt <- read_html(newslink[i]) %>%
  #       html_nodes("p") %>%
  #       html_text(), silent=TRUE)
  # txt <- gsub('\\n', ' ', txt)
  # txt <- paste(txt, collapse = ' ')
  # article[i] <- txt
  # j <- j + 1
  # Sys.sleep(0.1)
  # update progress bar
  setTxtProgressBar(pb, j)
}
Sys.sleep(1)
close(pb)
hansard.df <- data.frame(src, datePub, headlines, newslink, article,stringsAsFactors = FALSE)
