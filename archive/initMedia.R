# initMedia.R

# Init --------------------------------------------------------------------

library(rvest)
library(readr)

# Define Words:News Categories --------------------------------------------

cat.def <- read_csv("defense.csv")
cat.def <- data.frame("Keselamatan",cat.def)
names(cat.def)[1] = "Kategori"

cat.pol <- read_csv("politik.csv")
cat.pol <- data.frame("Politik",cat.pol)
names(cat.pol)[1] = "Kategori"

cat.sos <- read_csv("sosial.csv")
cat.sos <- data.frame("Sosial", cat.sos)
names(cat.sos)[1] = "Kategori"

cat.term <- rbind(cat.def, cat.pol, cat.sos)
cat.term$Kategori <- as.character(cat.term$Kategori)
cat.term$word <- as.character(cat.term$word)

# Define news.type ---------------------------------------------------------------

news.type <- c("thestar", "malaysiakini", "fmt", "borneopost",
               "nst", "malaysianinsight", "theedge", "roketkini",
               "themalaymailonline", "thesundaily", "thediplomat",
               "hmetro", "astroawani", "utusan", "sinarharian",
               "bernama", "kosmo", "beritaharian", "malaysia-chronicle",
               "malaysiandigest", "dailyexpress", "agendadaily", "keadilandaily")

news.cat <- c("akrab", "renggang", "renggang", "neutral",
              "akrab", "renggang", "renggang", "renggang",
              "neutral", "neutral", "neutral",
              "akrab", "akrab", "akrab", "akrab",
              "akrab", "akrab", "akrab", "renggang",
              "neutral", "neutral", "neutral", "renggang")

news.prop <- c("#slcontent3_6_sleft_0_storyDiv p", "#article_content p", "#content p",
               "p+ p", "p", "p", "#post-content p", ".entry-content span", ".article-content p", "p", "p", "p",
               ".detail-body-content", "p", "p", ".NewsText", "p:nth-child(14), br+ p",
               "p", "em , span", "p", ".headlines", "p", "p")

news.rat <- rbind.data.frame(c("akrab", 1.0),c("neutral", 0.6), c("renggang", 0.4))
names(news.rat) <- c("cat", "rat")

proplink <- data.frame(news.type, news.prop)
names(proplink) <- c("Page", "CSS")

media.type <- data.frame(news.type, news.cat, news.prop)
names(media.type) <- c("src", "cat", "css")

media <- media.type %>% 
  inner_join(news.rat)

# Save objects ------------------------------------------------------------

save(media,cat.term, file = "media.RData")
