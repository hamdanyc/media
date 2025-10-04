# Dictionary ------------------------------------------------------------------

load("newsData.RData")

pol1 <- wc %>% filter((n>1 & n<200),src=="utusan")
pol2 <- wc %>% filter((n>1 & n<200),src=="malaysiakini")

inner_join(pol1,pol2, by="word") %>%
  grep("[a-z]",word)


  tail() %>%
  write.csv(file = "pol.csv")