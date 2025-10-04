# Twitter Data Mining: newsTwitter.R
# Author: Kol Hamdan Yaccob

# Init-retrieve tweets ---------------------------------------------------------

library(twitteR)
library(ROAuth)
library(dplyr)

# Authentication ----------------------------------------------------------

consumer_key <- "WcKtqNfxfK6cqfFIEAG4mjGoM"
consumer_secret <-
  "MmcoM5FTJRKokEbiIpeipDpikSqNFTYROawHGAqawx5sJt8xhQ"
access_token <- "2331587536-RHMDgMCm3HbdX5zInSYcwrEtK3Tffy2Lwiema7y"
access_secret <- "PIK3tA3HvbF0bEXbAVgBzsjTyGR1ny1OUkzTlxftJ0Lcu"

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

# Get Data ----------------------------------------------------------------

datePub <- format(Sys.Date(), "%d %b %Y")
src <- "twitter.com"
headlines <- "Tanpa Tajuk"
newslink <- "news@twitter.com"
keysearch <- c("Angkatan+Tentera+Malaysia", "Malaysian+Armed+Forces","MAWILLA","UNIFIL", "TLDM", "TUDM",
               "Mat+Sabu", "#Justice4Adib","Tentera+Darat", "Tentera+Laut", "Tentera+Udara", "mindef",
               "bekas+tentera", "MALBATT", "Menteri+Pertahanan", "tentera","ESSZONE","Abu+Sayyaf",
               "malaysia+thailand", "malaysia+indonesia","daesh","islamic+state",
               "perajurit", "PVATM", "Majlis+Angkatan+Tentera", "bekas+anggota+tentera")

terms_search <- paste(keysearch, collapse = " OR ")

# retrieve keyterms
# r_twit <- searchTwitter(terms_search, n=100, resultType="recent")

# tryCatch({
#   r_twit <- searchTwitter(terms_search, n=100, resultType="recent")
# }, error = function(e) {
#   cat("Error. Skip.\n")
#   stop()
# })

try(r_twit <- searchTwitter(terms_search, n=200, resultType="recent"),
  silent=TRUE)

# convert to data frame
twitdf <- twListToDF(r_twit)

# try(if (exists(r_twit)){
#   twitdf <- twListToDF(r_twit)
# } else stop(),silent = TRUE)

# Create Data Frame -------------------------------------------------------

# news.all <- data.frame(src, datePub, headlines, newslink, article)
news.twt <- data.frame(src, datePub, "headlines"=strtrim(twitdf$text,25),
                       "newslink"="","article"=twitdf$text)

# Clean up ----------------------------------------------------------------

news.twt$article <- iconv(news.twt$article, "UTF-8", "ASCII", sub="")
news.twt$article=gsub("&amp", "", news.twt$article)
news.twt$article = gsub("&amp", "", news.twt$article)
news.twt$article = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", news.twt$article)
news.twt$article = gsub("@\\w+", "", news.twt$article)
# news.twt$article = gsub("[[:punct:]]", "", news.twt$article)
# news.twt$article = gsub("[[:digit:]]", "", news.twt$article)
# news.twt$article = gsub("http\\w+", "", news.twt$article)
news.twt$article = gsub("[ \t]{2,}", "", news.twt$article)
# news.twt$article = gsub("^\\s+|\\s+$", "", news.twt$article)

# newslink
news.twt$newslink <- news.twt$article %>%
  stringr::str_extract("https://t.co/[[:alnum:]]{1,10}")
news.twt$newslink <- iconv(news.twt$newslink, "UTF-8", "ASCII", sub="")
news.twt$headlines <- iconv(news.twt$headlines, "UTF-8", "ASCII", sub="")

news.twt$newslink=gsub("&amp", "", news.twt$newslink)
news.twt$newslink = gsub("&amp", "", news.twt$newslink)
news.twt$newslink = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", news.twt$newslink)
news.twt$newslink = gsub("@\\w+", "", news.twt$newslink)
# news.twt$newslink = gsub("[[:punct:]]", "", news.twt$newslink)
# news.twt$newslink = gsub("[[:digit:]]", "", news.twt$newslink)
# news.twt$newslink = gsub("http\\w+", "", news.twt$newslink)
news.twt$newslink = gsub("[ \t]{2,}", "", news.twt$newslink)
# news.twt$newslink = gsub("^\\s+|\\s+$", "", news.twt$newslink)

newstwit.df <- news.twt %>%
  filter(nchar(article) > 5) %>%
  distinct()

newstwit.df$article <- newstwit.df$article %>%
  stringr::str_replace("https://t.co/[[:alnum:]]{1,10}","")
