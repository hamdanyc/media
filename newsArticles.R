# newsArticles.R

# Init --------------------------------------------------------------------

library(dplyr)
library(tidytext)
library(readr)

# get utiliti functions
source("../function/myRfun.R")

# set status ext. tables

new.cat <- TRUE

# Read articles files ---------------------------------------------------------

thenews <- c(
  "utusan",
  "beritaharian",
  "thestar",
  "keadilandaily",
  "nst",
  "fmt",
  "malaysiakini",
  "thesundaily",
  "hmetro",
  "astroawani",
  "kosmo",
  "bernama",
  "malaysiainsight",
  "malaysiandigest",
  "themalaymailonline",
  "dailyexpress",
  "borneopost",
  "roketkini",
  "harakah",
  "theedge")

# Prepare media ----------------------------------------------------------------

try(
  for(i in thenews){
    
    i.rd <- read_delim(paste0(i,".csv"), "|",
            col_types = cols(datePub = col_skip(),
            Kategori_2 = col_skip()),
            locale = locale(encoding = "ASCII"))
    
    # break the text into individual tokens
    
    if(i == "utusan") {utusan.article <- i.rd}
    else 
      if(i == "beritaharian") {beritaharian.article <- i.rd}
    else 
      if(i == "thestar") {thestar.article <- i.rd}
    else 
      if(i == "keadilandaily") {keadilandaily.article <- i.rd}
    else 
      if(i == "nst") {nst.article <- i.rd}
    else
      if(i == "fmt") {fmt.article <- i.rd}
    else
      if(i == "malaysiakini") {malaysiakini.article <- i.rd}
    else
      if(i == "thesundaily") {thesundaily.article <- i.rd}
    else
      if(i == "hmetro") {hmetro.article <- i.rd}
    else
      if(i == "astroawani") {astroawani.article <- i.rd}
    else
      if(i == "kosmo") {kosmo.article <- i.rd}
    else
      if(i == "malaysiainsight") {malaysiainsight.article <- i.rd}
    else
      if(i == "bernama") {bernama.article <- i.rd}
    else
      if(i == "malaysiandigest") {malaysiandigest.article <- i.rd}
    else
      if(i == "malaysiainsight") {malaysiainsight.article <- i.rd}
    else
      if(i == "kosmo") {kosmo.article <- i.rd}
    else
      if(i == "themalaymailonline") {themalaymailonline.article <- i.rd}
    else
      if(i == "dailyexpress") {dailyexpress.article <- i.rd}
    else
      if(i == "theedge") {theedge.article <- i.rd}
    else
      if(i == "borneopost") {borneopost.article <- i.rd}
    else
      if(i == "roketkini") {roketkini.article <- i.rd}
    else
      if(i == "harakah") {harakah.article <- i.rd}
  })

# All articles -------------------------------------------------------------

article.all <- rbind(utusan.article,
                beritaharian.article,
                thestar.article,
                keadilandaily.article,
                nst.article,
                fmt.article,
                malaysiakini.article,
                thesundaily.article,
                hmetro.article,
                astroawani.article,
                kosmo.article,
                bernama.article,
                malaysiainsight.article,
                malaysiandigest.article,
                themalaymailonline.article,
                theedge.article,
                borneopost.article,
                roketkini.article,
                harakah.article,
                dailyexpress.article
                )

# Clean up ----------------------------------------------------------------

# Save Data ---------------------------------------------------------------

save.image(file="newsArticles.RData")

