# newsDailyKPI.R
## @knitr sentiment

library(tidytext)
library(tidyr)

load("newsdaily.RData")
load("binmy.RData")
load("media.RData")

news.eng <- c("nst", "thestar", "theedge", "dailyexpress",
              "malaysiandigest", "sinchew","themalaymailonline", "thesundaily",
              "borneopost", "fmt", "selangortimes")
news.my <- c("utusan", "bernama", "kosmo", "beritaharian", "amanahdaily", "agendadaily","roketkini",
            "keadilandaily", "malaysiakini", "hmetro", "sinarharian", "harakah", "astroawani")

def.key <-  c( "ESSCOM", "rentas sempadan", "laut China selatan", "krisis di wilayah",
               "antikeganasan", "border", "bomb ", "bom ", "south china sea", "pelampau",
               "extremist", "southern philippine", "militan", "militant", "threat of militant", "sayyaf",
               "Moro ", "southern thailand", "islamic state", "overlapping claimt", "militant arrested",
               "malaysia-thailand", "malaysia-indonesia", "malaysia-Filipina",
               "daesh"
)

crime.key <- c("samun", "curi ", "steal", "culik", "kidnap", "rusuh",  "robber",  "rompak",
               "leweng",  "felon",  "senjata",  "violen", "suicide",  "bribe",  "rasuah",  "ditahan",
               "pecah amanah", "CBT", "drug", "dadah", "rape", "rogol", "abuse", "salah guna", "JSJ",
               "Kanun Keseksaan", "Jabatan Siasatan Jenayah", "illegal gambling", "judi haram", 
               "firearm", "senjata api", "Agensi Antidadah Kebangsaan",
               "fraud" , "SPRM", "MACC", "detain", "misappropriation")

imigr.key <- c("eludup", "rentas", "sempadan", "cross border", "confiscate",
               "imigresen", "immigrant", "rampas", "pendatang asing")

atm.key <- c("Angkatan Tentera Malaysia", "panglima", "ATM", "Malaysian Armed Forces",
             "Armed Forces", "army", "navy ", "air force", "Hishammuddin Hussein",
             "Tentera Darat", "Tentera Laut", "Tentera Udara", "UNIFIL", "TLDM", "TUDM",
             "military", "soldier ", "rank and file", "regiment", "bekas tentera",
             "brigade", "briged", "Malbatt", "menteri pertahanan", "Johari Baharum",
             "perajurit", "PVATM", "bekas anggota tentera")

pol.key <- c(" BN ", "UMNO", "Parti Islam Se-Malaysia", "MCA", "Pakatan Harapan", "PKR",
             "MIC", "Parti Keadilan", "democratic action party", "Parti Pribumi Bersatu Malaysia",
             "Parti Gerakan", "MYPPP", "Parti Bangsa Bersatu (PBB)", "Parlimen",
             "SUPP", "Pertubuhan Pribumi Perkasa Malaysia", "Dewan Undangan Negeri",
             "PBRS", "UPKO", "SPDP", "PRS", "PCM", " PAN ", "PAS ", "PBS", "DAP", "PPBM",
             "Parti Amanah Nasional", "HINDRAF")

pru.key <- c( "pilihan raya", "Suruhanjaya Pilihan Raya", "PRU", "daftar pemilih",
              "voter", " Election Commission (EC)", "SPR ",
              "general election", "undi pos", "postal vote")

dstr.key <- c("banjir kilat", "flash flood", "fire", "kebakaran", "anging kencang", "kimia berbahaya",
              "tanah runtuh", "land slide", "heavy rain", "strong wind", "taufan", "kebocoran gas",
              "Jabatan Bomba dan Penyelamat Malaysia",
              "toxic gas", "gas leak", "typhoon", "oil spill", "tumpahan minyak", "collide")

news.tidy <- news.today %>% 
  filter(src %in% news.eng) %>% 
  select(src, headlines, article) %>% 
  group_by(headlines) %>% 
  unnest_tokens(word, article)

news.stm <- news.tidy %>%
  inner_join(get_sentiments("bing")) %>%
  group_by(headlines) %>% 
  count(sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

news.tmy <- news.today %>% 
  filter(src %in% news.my) %>% 
  select(src, headlines, article) %>% 
  group_by(headlines) %>% 
  unnest_tokens(word, article)

news.smy <- news.tmy %>%
  inner_join(binmy) %>%
  group_by(headlines) %>% 
  count(sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

news.stm <- news.stm %>% 
  rbind(news.smy)

# Calc KPI ----------------------------------------------------------------

def.kpi <- news.today %>%
  left_join(news.stm, by = "headlines") %>%
  filter(str_detect(article, paste(def.key, collapse = '|' ))) %>%
  mutate(kpi = sentiment)

crime.kpi <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(str_detect(article, paste(crime.key, collapse = '|' ))) %>%
  mutate(kpi = sentiment)

imigr.kpi <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(str_detect(article, paste(imigr.key, collapse = '|' ))) %>%
  mutate(kpi = sentiment)

atm.kpi <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(str_detect(article, paste(atm.key, collapse = '|' ))) %>%
  mutate(kpi = sentiment)

pol.kpi <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(str_detect(article, paste(pol.key, collapse = '|' ))) %>%
  mutate(kpi = sentiment)

pru.kpi <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(str_detect(article, paste(pru.key, collapse = '|' ))) %>%
  mutate(kpi = sentiment) 

dstr.kpi <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(str_detect(article, paste(dstr.key, collapse = '|' ))) %>%
  mutate(kpi = sentiment)

daily.kpi <- rbind(def.kpi, crime.kpi, imigr.kpi, atm.kpi, pol.kpi, pru.kpi, dstr.kpi)
save.image(file = "newsDailyKPI.RData")

# Outer Keywords ----------------------------------------------------------

word.out <- news.stm %>%
  anti_join(cat.term) %>%
  #inner_join(crime.key) %>% 
  inner_join(def.key)

