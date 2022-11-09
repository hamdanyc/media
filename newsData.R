# Init --------------------------------------------------------------------

library(dplyr)
library(tidytext)
library(stringr)
library(ggplot2)
library(wordcloud)
library(RColorBrewer)
library(readr)

# get utiliti functions
source("../function/myRfun.R")

# set status ext. tables

new.cat <- TRUE

pal2 <- brewer.pal(8,"Dark2")

# Read articles files ---------------------------------------------------------

# Utusan Melayu ----------------------------------------------------------------
utusan <- read_csv("utusan.csv", 
                   col_types = cols(datePub = col_skip(), 
                                    headlines = col_skip(), newslink = col_skip()))

# break the text into individual tokens
utusan <- utusan %>%
  unnest_tokens(word, article)

# Berita Harian -----------------------------------------------------------

beritaharian <- read_csv("beritaharian.csv", 
                    col_types = cols(datePub = col_skip(), 
                                    headlines = col_skip(), newslink = col_skip()))

# break the text into individual tokens

beritaharian <- beritaharian %>%
  unnest_tokens(word, article)

# Keadilan Daily ----------------------------------------------------------

keadilandaily <- read_csv("keadilandaily.csv", 
                          col_types = cols(datePub = col_skip(), 
                                           headlines = col_skip(), newslink = col_skip()))

# break the text into individual tokens

keadilandaily <- keadilandaily %>%
  unnest_tokens(word, article)

# The Star ----------------------------------------------------------------

thestar <- read_csv("thestar.csv", 
                    col_types = cols(datePub = col_skip(), 
                                     headlines = col_skip(), newslink = col_skip()))
  # break the text into individual tokens
  
thestar <- thestar %>%
  unnest_tokens(word, article)
  
# NST -----------------------------------------------------------

nst <- read_csv("nst.csv", 
                col_types = cols(datePub = col_skip(), 
                                 headlines = col_skip(), newslink = col_skip()))
# break the text into individual tokens

nst <- nst %>%
  unnest_tokens(word, article)

# Malaysiakini ------------------------------------------------------

malaysiakini <- read_csv("malaysiakini.csv", 
                         col_types = cols(datePub = col_skip(), 
                                          headlines = col_skip(), newslink = col_skip()))
# break the text into individual tokens

malaysiakini <- malaysiakini %>%
  unnest_tokens(word, article)

# Freemalaysia Today ------------------------------------------------------

fmt <- read_csv("fmt.csv", 
                col_types = cols(datePub = col_skip(), 
                                 headlines = col_skip(), newslink = col_skip()))
# break the text into individual tokens

fmt <- fmt %>%
  unnest_tokens(word, article)

# The Malaysian Insight ------------------------------------------------------

malaysianinsight <- read_csv("malaysianinsight.csv", 
                col_types = cols(datePub = col_skip(), 
                                 headlines = col_skip(), newslink = col_skip()))
# break the text into individual tokens

malaysianinsight <- malaysianinsight %>%
  unnest_tokens(word, article)

# The Malaymail ------------------------------------------------------

themalaymail <- read_csv("themalaymailonline.csv", 
                             col_types = cols(datePub = col_skip(), 
                                              headlines = col_skip(), newslink = col_skip()))
# break the text into individual tokens

themalaymail <- themalaymail %>%
  unnest_tokens(word, article)

# The sundaily ------------------------------------------------------

thesundaily <- read_csv("thesundaily.csv", 
                         col_types = cols(datePub = col_skip(), 
                                          headlines = col_skip(), newslink = col_skip()))
# break the text into individual tokens

thesundaily <- thesundaily %>%
  unnest_tokens(word, article)

# hmetro ------------------------------------------------------

hmetro <- read_csv("hmetro.csv", 
                        col_types = cols(datePub = col_skip(), 
                                         headlines = col_skip(), newslink = col_skip()))
# break the text into individual tokens

hmetro <- hmetro %>%
  unnest_tokens(word, article)

# astroawani ------------------------------------------------------

astroawani <- read_csv("astroawani.csv", 
                   col_types = cols(datePub = col_skip(), 
                                    headlines = col_skip(), newslink = col_skip()))
# break the text into individual tokens

astroawani <- astroawani %>%
  unnest_tokens(word, article)

# bernama ------------------------------------------------------

bernama <- read_csv("bernama.csv", 
                       col_types = cols(datePub = col_skip(), 
                                        headlines = col_skip(), newslink = col_skip()))
# break the text into individual tokens

bernama <- bernama %>%
  unnest_tokens(word, article)

# Merge articles -------------------------------------------------------------

textDf <- rbind(utusan,
                beritaharian,
                thestar,
                keadilandaily,
                nst,
                malaysiakini,
                fmt,
                malaysianinsight,
                themalaymail,
                thesundaily,
                hmetro,
                astroawani,
                bernama)

# Get Media:Source:Cat -----------------------------------------------------------

load("media.RData")

# Cleanup -----------------------------------------------------------------

# textDf <- textDf %>%
#   filter(
#     !str_detect(word, "[0-9]"),
#     !str_detect(word, "link"),!str_detect(word, "taboola")
#   )

# load custom_stopwords:malay
# load("stopwordMalay.RData")

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

# Save Data ---------------------------------------------------------------

save.image(file="newsData.RData")

