# sinchewZh.R

# Init --------------------------------------------------------------------

library(rvest)
library(dplyr)
library(RYandexTranslate)

# load traslate fun
# usage data=translate(api_key, text=txt, lang = "en")
load(file="translate.RData")

# Read html ---------------------------------------------------------------

theNews <- read_html("http://www.sinchew.com.my/")

headlines <- theNews %>%
  html_nodes(".standard-title-font-for-displaying-post-excerpt a") %>%
  html_text()

newslink <- theNews %>%
  html_nodes(".standard-title-font-for-displaying-post-excerpt a") %>%
  html_attr("href")

# Translate Headlines -----------------------------------------------------
# usage data = translate(api_key, text = thetext, lang = "en")

# Simplifies output to a vector
trhead <- sapply (headlines, function(x) translate(api_key, text = x, lang = "en")) %>%
  sapply( paste0, collapse="")

trhdr <- data.frame(trhead) %>% 
  filter(trhead != "zh-en")

# Verify link -------------------------------------------------------------

maxpage <- 1
no.links <- length(headlines)
article <- matrix("", no.links*maxpage)
datePub <- format(Sys.Date(), "%d %b %Y")
src <- matrix("sinchewzh",no.links*maxpage)
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
    newsurl[j,1] <- paste0("http://www.mysinchew.com.my", newslink[j])
}

# Follow link -------------------------------------------------------------

# try(
#   for(i in 2:maxpage) {
# 
#     theNews <- read_html(paste0("http://www.sinchew.com.my/topic/%E6%A7%9F%E5%B7%9E%E6%B0%B4%E7%81%BE?page=",i,".html"))
# 
#     headlines <- theNews %>%
#       html_nodes(".standard-title-font-for-displaying-post-excerpt a") %>%
#       html_text()
# 
#     try(
#     for (j in (1:no.links)) {
#       if (headlines[j] != "")
#         newstitles[j, i] <- headlines[j]
#     })
# 
#     newslink <- theNews %>%
#       html_nodes(".standard-title-font-for-displaying-post-excerpt a") %>%
#       html_attr("href")
# 
#     try(
#     for (j in (1:no.links)){
#       if (newslink[j] != "")
#         newsurl[j,i] <- paste0("http://www.sinchew.com.my", newslink[j])
#     })
# 
#   })

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
sinchewzh.df <- data.frame(src, datePub, headlines, newslink, article)
