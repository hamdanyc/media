# mytoday.R

# Init --------------------------------------------------------------------

library(rvest)
library(dplyr)

# Read html ---------------------------------------------------------------

theNews <- read_html("http://www.malaysia-today.net/")
# ss <- html_session("http://www.thestar.com.my/news/nation")

headlines <- theNews %>%
  html_nodes(".columns-3 .post-url") %>%
  html_text()

newslink <- theNews %>%
  html_nodes(".columns-3 .post-url") %>%
  html_attr("href")

# Verify link -------------------------------------------------------------

no.links = length(newslink)
article <- matrix("",no.links)
datePub <- format(Sys.Date(), "%d %b %Y")
src <- "malaysia-today"

# Scrape article ----------------------------------------------------------

for (i in 1:no.links) {
  txt <- read_html(newslink[i]) %>%
    html_nodes("p") %>%
    html_text()
  txt <- gsub('\\n', ' ', txt)
  txt <- paste(txt, collapse = ' ')
  article[i] <- txt
}

# Write news.csv -------------------------------------------------------

data.frame(src, datePub, headlines, newslink, article) %>%
  write.csv(file="malaysia-today.csv", row.names = FALSE)
