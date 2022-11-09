# newsdaily2.R
# schedule at 0700 every day

# Problems:
    # "malaysiainsight.R",
    # "hemalaymailonline.R",
    # "thestar",
# newsArticles.R
# newAnalysis.R
# newsAnalysisBack.R -- restore daily news
# newsdailyWrite.R -- alternate from recovered data

thenews <- c(
  "utusan",
  "beritaharian",
  "keadilandaily",
  "nst",
  "fmt",
  "malaysiakini",
  "thesundaily",
  "hmetro",
  "astroawani",
  "kosmo",
  "bernama",
  "malaysiainsight",
  "malaysiandigest",
  "themalaymailonline",
  "dailyexpress",
  "borneopost",
  "roketkini",
  "harakah",
  "theedge")

try(
  for (i in thenews) {
    source(paste0(i,".R"))
  })

# Create df -------------------------------------------------------------

news.today <- rbind(utusan.df,
                     beritaharian.df,
                     keadilandaily.df,
                     nst.df,
                     fmt.df,
                     malaysiakini.df,
                     thesundaily.df,
                     hmetro.df,
                     astroawani.df,
                     kosmo.df,
                     bernama.df,
                     malaysiainsight.df,
                     malaysiandigest.df,
                     themalaymailonline.df,
                     theedge.df,
                     borneopost.df,
                     roketkini.df,
                     harakah.df,
                     dailyexpress.df)

# Media Cat ----------------------------------------------------------------

news.today$article <- as.character(news.today$article)
textDf <- tidytext::unnest_tokens(news.today, word, article)
prob.cat <- textDf %>%   
  inner_join(cat.term) %>%
  select(headlines, Kategori) %>%
  group_by(headlines) %>%
  summarise(Kategori_1=first(Kategori),Kategori_2=last(Kategori))

# Save and Write to file ---------------------------------------------------------------

news.today %>% 
  inner_join(prob.cat) %>% 
  write.table(file="newsdaily.csv", row.names = FALSE, sep = "|", quote=TRUE)

save(file = "newsdaily.RData", news.today)
