# negUpd.R

negeri.cnt <- news.loc %>%
  select(negeri) %>% 
  group_by(negeri) %>% 
  count()

names(negeri.cnt)[1] <- "kod neg"

neg.desc <- c("Johor", "Kedah", "Kelantan", "WP Kuala Lumpur", "WP Labuan",
              "Melaka", "N. Sembilan", "Pahang", "WP Putrajaya", "Perlis",
              "P. Pinang", "Perak", "Sabah", "Selangor", "Sarawak", "Terengganu")
neg.my <- data.frame(negeri.cnt, neg.desc)

save(news.loc, neg.my, file =  "bandar.RData")
