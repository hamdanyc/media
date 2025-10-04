# top nth important word

library(tidytext)
library(stringr)

wc <- wc %>%
  bind_tf_idf(word, src, n)

wc %>%
  filter(tf_idf > 0.06722) %>% 
  top_n(20) %>%
  ggplot(aes(word, tf_idf, fill = src)) +
  geom_col() +
  labs(x = NULL, y = "tf-idf") +
  coord_flip()

wc %>% 
  inner_join(cat.term) %>%
  bind_tf_idf(word, src,n) %>%  
  arrange(desc(tf_idf)) %>% 
  top_n(3) %>%
  ggplot(aes(word, tf_idf, fill = Kategori)) +
  geom_col() +
  labs(x = NULL, y = "tf-idf") +
  coord_flip()

wc %>% 
  inner_join(cat.term) %>%
  bind_tf_idf(word, src,n) %>% 
  group_by(Kategori) %>% 
  arrange(desc(Kategori, tf_idf)) %>% 
  top_n(10) %>% 
  View()

# eg: string_patterns <- c("stringpattern1", "stringpattern2")
# df %>% filter ( str_detect ( col_with_strings, paste ( string_patterns, collapse = '|' )))

keywords <- c("perdana", "pasukan")

article.all %>%
  filter(str_detect(article, paste(keywords, collapse = '|' ))) %>% 
  select(src, headlines, article) %>%
  View()
