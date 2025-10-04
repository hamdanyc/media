# ggNewsEn.R
# English keywords

# Init --------------------------------------------------------------------

library(rvest)
library(dplyr)

# Set Keywords ------------------------------------------------------------

keyWord <- "armed+forces+malaysia"
gg <- "https://news.google.com/news/search/section/q/"
searchKey <- paste(gg,keyWord,"/?hl=en-MY&ned=en_my", sep = '')

# Read html ---------------------------------------------------------------

theNews <- read_html(searchKey)

headlines <- theNews %>%
  html_nodes(".kWyHVd .ME7ew") %>%
  html_text()

newslink <- theNews %>%
  html_nodes(".kWyHVd .ME7ew") %>%
  html_attr("href")

# Define news.type ---------------------------------------------------------------

news.type <- c("thestar", "malaysiakini", "freemalaysiatoday",
               "nst", "themalaysianinsight", "theedgemarkets",
               "themalaymailonline", "thesundaily", "thediplomat",
               "hmetro", "astroawani", "utusan", "sinarharian",
               "bernama", "kosmo", "bharian", "malaysia-chronicle",
               "malaysiandigest", "dailyexpress", "agendadaily")

news.cat <- c("akrab", "renggang", "renggang",
              "akrab", "renggang", "neutral",
              "neutral", "neutral", "neutral",
              "akrab", "akrab", "akrab", "akrab",
              "akrab", "akrab", "akrab", "renggang",
              "neutral", "neutral", "neutral")

news.prop <- c("#slcontent3_6_sleft_0_storyDiv p", "#article_content p", 
               "p+ p", "p", "p", "#post-content p", ".article-content p", "p", "p", "p",
               ".detail-body-content", "p", "p", ".NewsText", "p:nth-child(14), br+ p",
               "p", "em , span", "p", ".headlines", "p")

news.rat <- rbind.data.frame(c("akrab", 1.0),c("neutral", 0.6), c("renggang", 0.4))
names(news.rat) <- c("cat", "rat")

proplink <- data.frame(news.type, news.prop)
names(proplink) <- c("Page", "CSS")

media.type <- data.frame(news.type, news.cat, news.prop)
names(media.type) <- c("src", "cat", "css")

media <- media.type %>% 
  inner_join(news.rat)

# theNews %>% 
#   html_nodes(".m a") %>%
#   html_attrs()

no.links = length(newslink)
article <- matrix("",no.links)
icss <- matrix("",no.links)
src <- matrix("",no.links)
datePub <- format(Sys.time(), "%d %b %Y")

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

# source("newsCat.R")

news.csv <- data.frame(icss$src, datePub, headlines, newslink, article)

# Write csv -------------------------------------------------------

news.csv %>% 
  inner_join(prob.cat) %>% 
  write.table(file="ggNewsEng.csv", append = FALSE, sep = ",", row.names = FALSE)

# Save objects ------------------------------------------------------------

save(media, file = "ggENews.RData")
