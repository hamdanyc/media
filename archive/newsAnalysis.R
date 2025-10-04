# newsAnalysis.R
# run once daily

# Init --------------------------------------------------------------------

library(dplyr)
library(tidytext)
library(readr)

# get utiliti functions
source("../function/myRfun.R")

# set status ext. tables

load("daily.RData")
load("newsdaily.RData")

# Prepare media ----------------------------------------------------------------

tdf <- news.today %>%
  unnest_tokens(word, article)

# Get Media:Source:Cat -----------------------------------------------------------

load("media.RData")

# Cleanup -----------------------------------------------------------------

# load stop_word english
data(stop_words)
load("stopwordMalay.RData")

# remove stop words
tdf <- tdf %>%
  anti_join(stop_words)

tdf <- tdf %>%
  anti_join(stopword_malay)

# Analysis ----------------------------------------------------------------

source("newsSummary.R")

datePub <- format(Sys.Date(), "%Y/%m/%d")
idx <- aggregate(score ~ Kategori, ws, sum)
daily.kpi <- data.frame(Tarikh=datePub, Kategori=idx$Kategori, Skor=round(idx$score*100,1))

daily.kpi %>%
  write.table(file="kpi.csv", row.names = FALSE, fileEncoding = "ASCII", sep = "|", quote=FALSE)

kpi.data <- rbind(daily.kpi, kpi.data)
daily.run <- TRUE

# Save Data ---------------------------------------------------------------

save.image(file="newsData.RData")
save(file = "daily.RData", kpi.data, daily.run)
write.csv(kpi.data, file = "kpi_data.csv", quote = FALSE, row.names = FALSE)

