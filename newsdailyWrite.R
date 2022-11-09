# newsdailyWrite.R
# alternative to newsdaily2.R 

# Init --------------------------------------------------------------------

library(dplyr)

load("newsdaily.RData")
load("media.RData")

# Media Cat ----------------------------------------------------------------

news.csv <- news.today
news.csv$article <- as.character(news.csv$article)
textDf <- tidytext::unnest_tokens(news.csv, word, article)
prob.cat <- textDf %>%   
  inner_join(cat.term) %>%
  select(headlines, Kategori) %>%
  group_by(headlines) %>%
  summarise(Kategori_1=first(Kategori),Kategori_2=last(Kategori))

# Save and Write to file ---------------------------------------------------------------

news.csv %>% 
  inner_join(prob.cat) %>% 
  write.table(file="newsdaily.csv", row.names = FALSE, sep = "|", quote=TRUE)

# save.image(file = "newsdaily.RData")

