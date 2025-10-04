# create word count from articles

# Word count --------------------------------------------------------------

espnlc <- espn %>% 
  mutate(word=tolower(espn$word), Kategori)

wc <- tdf %>% 
  inner_join(espnlc) %>%
  select(src, word) %>% 
  count(src, word)

# aggregate(n ~src, wc, sum)

# wc100 <- wc %>% 
#   filter(n > 3 & n < 100)
# 
# wc100 <- na.omit(wc100)

result <- wc %>%   
  inner_join(espnlc) %>%
  inner_join(media) %>%
  select(Kategori, src, n, rat)

# aggregate(n ~Kategori+src, result, sum)

wr <- result %>%
  select(Kategori,src,rat,n) %>% 
  group_by(Kategori, src) %>%
  summarise (n = n()) %>%
  mutate(pct = n / sum(n))

ws <- wr %>%
  inner_join(media) %>%
  mutate(score = as.numeric(as.character(rat))*pct) %>%
  select(Kategori,src,rat,pct,score) %>% 
  group_by(Kategori)

# aggregate(score ~ src+Kategori, ws, sum)
idx <- aggregate(score ~ Kategori, ws, sum)

# tf_idf
wc %>% bind_tf_idf(word, src,n) %>%  arrange(desc(tf_idf))

wc %>% 
  inner_join(espnlc) %>%
  bind_tf_idf(word, src,n) %>%  
  arrange(desc(tf_idf)) %>% 
  # filter(tf_idf > 0.0016722) %>% 
  View()

# top nth word by Kategori - "Keselamatan", "Politik", "Sosial"
# Fun Keyword by Cat ------------------------------------------------------

keywordbyCat <- function (cat, nKey){
  wc %>% 
    inner_join(espnlc) %>%
    filter(Kategori == cat) %>% 
    inner_join(media) %>%
    group_by(Kategori) %>% 
    select(Kategori, word, rat, n) %>% 
    arrange(n) %>%
    tail(nKey)
}

# 7th Word by Def, Soc and Pol with score ---------------------------------------

defTbl <- keywordbyCat("Keselamatan", 11)
crmTbl <- keywordbyCat("Jenayah",11)
socTbl <- keywordbyCat("Bencana",11)
rsTbl <- keywordbyCat("Rentas Sempadan",11)
atmTbl <- keywordbyCat("Ketenteraan",11)
polTbl <- keywordbyCat("Politik",11)
pruTbl <- keywordbyCat("Pilihan Raya",11)

# add score to defTbl
defTbl[, 5] <-  apply(defTbl[4], 2, 
    function(x) defTbl$n * as.numeric(as.character(defTbl$rat)) / sum(defTbl$n))
names(defTbl)[5] <- "score"

# add score to crmTbl
crmTbl[, 5] <-  apply(crmTbl[4], 2, 
                      function(x) crmTbl$n * as.numeric(as.character(crmTbl$rat)) / sum(pruTbl$n))
names(crmTbl)[5] <- "score"

# add score to socTbl
socTbl[, 5] <-  apply(socTbl[4], 2, 
    function(x) socTbl$n * as.numeric(as.character(socTbl$rat)) / sum(socTbl$n))
names(socTbl)[5] <- "score"

# add score to rsTbl
rsTbl[, 5] <-  apply(rsTbl[4], 2, 
                      function(x) rsTbl$n * as.numeric(as.character(rsTbl$rat)) / sum(defTbl$n))
names(defTbl)[5] <- "score"

# add score to atmTbl
atmTbl[, 5] <-  apply(atmTbl[4], 2, 
                      function(x) atmTbl$n * as.numeric(as.character(atmTbl$rat)) / sum(defTbl$n))
names(atmTbl)[5] <- "score"

# add score to polTbl
polTbl[, 5] <-  apply(polTbl[4], 2, 
                      function(x) polTbl$n * as.numeric(as.character(pruTbl$rat)) / sum(pruTbl$n))
names(polTbl)[5] <- "score"

# add score to polTbl
pruTbl[, 5] <-  apply(pruTbl[4], 2, 
    function(x) pruTbl$n * as.numeric(as.character(pruTbl$rat)) / sum(pruTbl$n))
names(pruTbl)[5] <- "score"

# Word Cloud --------------------------------------------------------------

# wcat <- wc %>%
#   inner_join(cat.term) %>%
#   select(Kategori, src, word, n)
# 
# wcat %>%
#   # filter(Kategori == "Sosial", src == "Lim Kit Siang") %>%
#   select(word,Kategori,n) %>%
#   with(wordcloud(word, n, max.words = 25, min.freq = 3,
#                  scale = c(0.5, 3),  colors=pal2))

