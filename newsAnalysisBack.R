# newsAnalysisBack.R

# Init --------------------------------------------------------------------

library(dplyr)
library(tidytext)
library(readr)

# get utiliti functions
source("../function/myRfun.R")

# set status ext. tables

daily.run <- TRUE
load("daily.RData")

# Read articles files ---------------------------------------------------------

thenews <- c(
  "utusan.RData",
  "beritaharian.RData",
  "thestar.RData",
  "keadilandaily.RData",
  "nst.RData",
  "fmt.RData",
  "malaysiakini.RData",
  "thesundaily.RData",
  "hmetro.RData",
  "astroawani.RData",
  "kosmo.RData",
  "bernama.RData",
  "malaysiainsight.RData",
  "malaysiandigest.RData",
  "themalaymailonline.RData",
  "dailyexpress.RData",
  "borneopost.RData",
  "harakah.RData",
  "theedge.RData",
  "roketkini.RData")

# RData <- list.files(pattern="*.RData", full.names="TRUE")
# load(RData[1])

# Merge articles -------------------------------------------------------------
# malaysiandigest, themalaymailonline, theedge

try(
  for (i in thenews) {
    load(i)
    if (i == "utusan.RData"){
      utusan <- news.last } 
    else 
      if (i == "beritaharian.RData"){
        beritaharian <- news.last }
    else 
      if (i == "thestar.RData"){
        thestar <- news.last }
    else 
      if (i == "keadilandaily.RData"){
        keadilandaily <- news.last }
    else 
      if (i == "nst.RData"){
        nst <- news.last }
    else 
      if (i == "fmt.RData"){
        fmt <- news.last }
    else 
      if (i == "malaysiakini.RData"){
        malaysiakini <- news.last }
    else 
      if (i == "thesundaily.RData"){
        thesundaily <- news.last }
    else 
      if (i == "hmetro.RData"){
        hmetro <- news.last }
    else 
      if (i == "astroawani.RData"){
        astroawani <- news.last }
    else 
      if (i == "kosmo.RData"){
        kosmo <- news.last }
    else 
      if (i == "bernama.RData"){
        bernama <- news.last }
    else 
      if (i == "malaysiainsight.RData"){
        malaysiainsight <- news.last }
    else 
      if (i == "malaysiandigest.RData"){
        malaysiandigest <- news.last }
    else 
      if (i == "themalaymailonline.RData"){
        themalaymailonline <- news.last }
    else 
      if (i == "dailyexpress.RData"){
        dailyexpress <- news.last }
    else 
      if (i == "borneopost.RData"){
        borneopost <- news.last }
    else 
      if (i == "harakah.RData"){
        harakah <- news.last }
    else 
      if (i == "theedge.RData"){
        theedge <- news.last }
    else 
      if (i == "roketkini.RData"){
        roketkini <- news.last }
  })

news.today <- rbind(utusan,
                beritaharian,
                thestar,
                keadilandaily,
                nst,
                fmt,
                malaysiakini,
                thesundaily,
                hmetro,
                astroawani,
                kosmo,
                bernama,
                malaysiainsight,
                malaysiandigest,
                themalaymailonline,
                theedge,
                borneopost,
                roketkini,
                harakah,
                dailyexpress)

# Unnest Token ------------------------------------------------------------

textDf <- news.today %>% 
  unnest_tokens(word, article)

# Get Media:Source:Cat -----------------------------------------------------------

load("media.RData")

# Cleanup -----------------------------------------------------------------

# load stop_word english
data(stop_words)
load("stopwordMalay.RData")

# remove stop words
textDf <- textDf %>%
  anti_join(stop_words)

textDf <- textDf %>%
  anti_join(stopword_malay)

# Analysis ----------------------------------------------------------------

source("newsSummary.R")

if (daily.run) {
  
  datePub <- format(Sys.Date(), "%d %b %Y")
  idx <- aggregate(score ~ Kategori, ws, sum)
  daily.kpi <- data.frame(Tarikh=datePub, Kategori=idx$Kategori, Skor=round(idx$score*100,1))
  
  daily.kpi %>% 
    write.table(file="kpi.csv", row.names = FALSE, fileEncoding = "ASCII", sep = "|", quote=FALSE)

  # kpi.data <- rbind(daily.kpi, kpi.data)
}

# Save Data ---------------------------------------------------------------

save.image(file="newsData.RData") # refered by newsRpt.Rmd
save(file = "daily.RData", kpi.data, article.done) # refered by newsAnalysisBack.Rmd
save(file="newstoday.RData", news.today) # alternate data to newsdaily.R

