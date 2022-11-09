# ggNewsMy.R

# Init --------------------------------------------------------------------

library(rvest)
library(tidytext)
library(readr)

# Set Keywords ------------------------------------------------------------

keyWord <- "angkatan+tentera+malaysia"
gg <- "https://news.google.com/news/search/section/q/"
searchKey <- paste(gg,keyWord,"/?hl=en-MY&ned=en_my", sep = '')
datePub <- format(Sys.time(), "%d %b %Y")

# Read html ---------------------------------------------------------------

theNews <- read_html(searchKey)

headlines <- theNews %>%
  html_nodes(".kWyHVd .ME7ew") %>%
  html_text()

newslink <- theNews %>%
  html_nodes(".kWyHVd .ME7ew") %>%
  html_attr("href")

no.links = length(newslink)
article <- matrix("",no.links)
icss <- matrix("",no.links)
src <- matrix("",no.links)
# Load Media --------------------------------------------------------------

load("media.RData")

# Match news to CSS -------------------------------------------------------

cssMatch <- function() {
  result <- matrix("", no.links)
  css <- matrix("", no.links)
  src <- matrix("", no.links)
  n <- nrow(media)
  for (i in 1:length(newslink)) {
    for (j in 1:n) {
      if (grepl(media[j, 1], newslink[i])) {
        css[i] <- as.character(media[j, 3])
        src[i] <- as.character(media[j, 1])
        break
      }
    }
  }
  result <- data.frame(src, css)
  return(result)
}

# CSS by media type ----------------------------------------------------------------

icss <- cssMatch()

# Harvest article ---------------------------------------------------------

for (i in 1:no.links) {
  try(
    if (icss$src[i] != "") {
      txt <- read_html(newslink[i]) %>% 
        html_nodes(as.character(icss$css[i])) %>%
        html_text()
      txt <- gsub('\\n', ' ', txt)
      txt <- paste(txt, collapse = ' ')
      article[i] <- txt
    }
  )
}

# Set Media's Category ----------------------------------------------------

source("newsCat.R")

news.csv <- data.frame(icss$src, datePub, headlines, newslink, article)

# Write csv -------------------------------------------------------

news.csv %>% 
  inner_join(prob.cat) %>% 
  write.table(file="ggNewsMal.csv", append = FALSE, sep = ",", row.names = FALSE)
