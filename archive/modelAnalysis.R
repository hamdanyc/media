# modelAnalysis.R

library(wordVectors)
library(tidytext)
library(dplyr)

# Read in model ------------------------------------------------------

model <- read.binary.vectors("media.vector.bin")

# Read Article ------------------------------------------------------------

# write.table(topic_txt[100],"sample.txt")
# article.txt <- readtext::readtext("turkey_1.txt")

# Search keyword %in% the model ------------------------------------------------------------

model %>% improve_vectorspace() %>% 
  closest_to("imigresen",25)
model %>% improve_vectorspace() %>%
  closest_to("bencana",25)
model %>% improve_vectorspace() %>%
  closest_to("keganasan")
model %>% improve_vectorspace() %>%
  closest_to("mindef")
model %>% improve_vectorspace() %>%
  closest_to("jenayah")
model %>% improve_vectorspace() %>%
  closest_to("militan")
model %>% improve_vectorspace() %>%
  closest_to("disaster")
model %>% improve_vectorspace() %>%
  closest_to("ekonomi")
model %>% improve_vectorspace() %>%
  closest_to("crime", 25)
model %>% improve_vectorspace() %>%
  closest_to("pertahanan")
model %>% improve_vectorspace() %>%
  closest_to("sosial", 25)
model %>% improve_vectorspace() %>%
  closest_to("parti", 25)
model %>% closest_to(~ "alliance" + "security" + "economy")
model %>% closest_to(~ "keselamatan" + "pertahanan" + "politik")

key.concept <- c("bencana", "keselamatan", "politik", "serantau", 
                 "ekonomi", "pertahanan", "jenayah", "ketenteraan")

# multiple search
concept <- model %>% 
  nearest_to(model[[key.concept]],55) %>% names()
sample(concept)

topic.concept <- model %>%
  improve_vectorspace() %>%
  closest_to(model[[key.concept]],100, fancy_names = F)

# Apply to article --------------------------------------------------------
article.txt <- readtext::readtext("media.txt")
d <- data_frame(txt = article.txt$text)

wt <- d %>%
  unnest_tokens(word, txt)

# calc word freq
wf <- wt %>%
  count(word, sort = TRUE) %>%
  ungroup()

# joint with key concept

wf %>%
  inner_join(topic.concept) %>% 
  select(word,n)

# Save objects ------------------------------------------------------------
save.image(file = "modelAnalysis.RData")
