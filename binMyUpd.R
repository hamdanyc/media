# bmyUpd.R
## @knitr sentiment

# library(tidytext)
# library(tidyr)
library(dplyr)

# load("newsdaily.RData")
# load("stopwordMalay.RData")
load("binmy.RData")

bmy <- read.csv("binMy.csv")
  
binmy <- bmy %>% 
  rbind(binmy) %>% 
  unique()

save(binmy, file = "binmy.RData")

# bmy <- bmy %>% 
#   mutate(sentiment=replace(bmy$sentiment, bmy$sentiment == "", "positive")) %>%
#   as.data.frame()
# 
# bmy %>%  
#   write.csv(file = "bmy.csv", row.names = FALSE, quote = FALSE)

