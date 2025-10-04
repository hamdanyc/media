# newsCat.R

# Read Data Frame ---------------------------------------------------------------
# break the text into individual tokens

news.csv <- data.frame(src, datePub, headlines, newslink, article)
news.csv$article <- as.character(news.csv$article)

textDf <- tidytext::unnest_tokens(news.csv, word, article)

# Get Media:Source:Cat -----------------------------------------------------------
load("media.RData")

# Media Cat ----------------------------------------------------------------
prob.cat <- textDf %>%   
  inner_join(cat.term) %>%
  select(headlines, Kategori) %>%
  group_by(headlines) %>%
  summarise(Kategori_1=first(Kategori),Kategori_2=last(Kategori))
