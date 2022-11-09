atm.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(str_detect(article, paste(atm.key, collapse = '|' ))) %>%
  select(article)
  
  word.idx(atm.txt$article,atm.key)

  
  str_detect(atm.txt$article, paste(atm.key, collapse = '|' )) %>% 
    table()
  