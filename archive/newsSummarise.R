# newsSummarise.R

library(LSAfun)
library(dplyr)

load("newsdaily.RData")

# Prepare Article ---------------------------------------------------------

# start stop watch
ptm <- proc.time()

txt <- news.today[42,] %>%
  select(article)
txt <- as.character(txt)


# Summarise it ------------------------------------------------------------
txt %>% 
  genericSummary(k=3)

# stop stop watch
proc.time() - ptm
