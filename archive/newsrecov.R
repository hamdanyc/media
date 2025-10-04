# newsrecov.R

run.lst <- c("newsDailyKPIVer2.R", "newsRdr.R","newsMail.R")

# Media Clean up ----------------------------------------------------------------

news.today <- news.tmp
news.today <- news.today %>%
  filter(headlines != "")
news.today <- unique(news.today)
datePub <- format(Sys.Date(), "%Y/%m/%d")
dt <- format(Sys.Date(), "%Y_%m_%d")
news.today$datePub <- datePub
# news.today$headlines <- trimws(news.today$headlines)
# news.today$article <- trimws(news.today$article)
news.today$article <- stringr::str_replace_all(news.today$article, pattern = "[^[:print:]]", " ")
news.today$article <- stringr::str_replace_all(news.today$article,
                                               pattern = "googletag.cmd.push|function", "")
news.today$article <- stringr::str_replace_all(news.today$article,
                                               pattern = "googletag.display", "")
news.today$article <- stringr::str_replace_all(news.today$article,
                                               pattern = "mm-story-320x100", "")
news.today$article <- stringr::str_replace_all(news.today$article,
                                               pattern = "div-gpt-ad-1471855201557-0", "")
news.today$article <- stringr::str_replace_all(news.today$article,
                                               pattern = "[();]","")
news.today$article <- iconv(news.today$article, "UTF-8", "ASCII", sub="")

# news.today$article <- stringr::str_replace_all(news.today$article, pattern = "[^a-zA-Z0-9.\\s]", " ")
# Shrink down to just one white space
# news.today$article <- stringr::str_replace_all(news.today$article,"[\\s]+", " ")
# news.today$headlines <- stringr::str_replace_all(news.today$headlines, pattern = "[[:cntrl:]]", " ")
# news.today$article <- stringr::str_replace_all(news.today$article, pattern = "[[:punct:]]", "")
# news.today$article <- stringr::str_replace_all(news.today$article, pattern = "<U+2028>", "")
news.today$article <- as.character(news.today$article)

# news.today <- news.today %>%
#   anti_join(news.last, by="headlines")

# assign categories to each article
# textDf <- tidytext::unnest_tokens(news.today, word, article)
# prob.cat <- textDf %>%   
#   inner_join(cat.term) %>%
#   select(headlines, Kategori) %>%
#   group_by(headlines) %>%
#   summarise(Kategori_1=first(Kategori),Kategori_2=last(Kategori))

# Save and Write to file ---------------------------------------------------------------

# daily.run <- FALSE
# if(daily.run){ # update news.today as done
#   
#   if(count(news.today) > 0){
#     news.last <- news.today %>% 
#       select(src, headlines) %>% 
#       rbind(news.last)
#   }
#   
#   tgt <- paste("arkib/",dt,"news.csv", sep = "")
#   news.today %>%
#     write.table(file=tgt, row.names = FALSE, sep = "|", quote=FALSE)
#   
#   news.today %>%
#     inner_join(prob.cat) %>%
#     write.table(file="newsdaily.csv", row.names = FALSE, sep = "|", quote=FALSE)
# }

save(file = "newsdaily.RData", news.today, news.last)

try(
  for (i in run.lst) {
    source(i)
  })
