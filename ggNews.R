# ggNews.R
# English keywords

# Init --------------------------------------------------------------------

library(rvest)
library(dplyr)

# Set Keywords ------------------------------------------------------------

keyWord <- as.character(c("armed+forces+malaysia", "angkatan+tentera+malaysia",
                          "military+malaysia", "defence+malaysia"))
news.lst <- c("news.key1", "news.key2", "news.key3")

# Get Media:Source:Cat -----------------------------------------------------------

load("media.RData")

gg <- "https://news.google.com/news/search/section/q/"

try(
  for(ik in 1:length(keyWord)){
    searchKey <- paste0(gg,keyWord[ik],"/?hl=en-MY&ned=en_my")
    
    source("ggReadhtml.R")
    
    # Set Media's Category ----------------------------------------------------
    # Read Data Frame
    # break the text into individual tokens
    
    news.csv <- data.frame(icss$src, datePub, headlines, newslink, article)
    news.csv$article <- as.character(news.csv$article)
    
    textDf <- tidytext::unnest_tokens(news.csv, word, article)
    
    # Media Cat ----------------------------------------------------------------
    prob.cat <- textDf %>%   
      inner_join(cat.term) %>%
      select(headlines, Kategori) %>%
      group_by(headlines) %>%
      summarise(Kategori_1=first(Kategori),Kategori_2=last(Kategori))
    
    news.csv <- news.csv %>% 
      inner_join(prob.cat)
    
    if (ik == 1) news.key1 <- news.csv
    else if (ik == 2) news.key2 <- news.csv
    else if (ik == 3) news.key3 <- news.csv
    else if (ik == 3) news.key4 <- news.csv

  })

# Write csv -------------------------------------------------------

news.csv <- rbind(news.key1, news.key2, news.key3)
news.csv %>% 
  write.table(file="ggNews.csv", append = FALSE, sep = "|"
      , row.names = FALSE, fileEncoding = "ASCII")

# Save objects ------------------------------------------------------------

save(media, file = "ggENews.RData")
