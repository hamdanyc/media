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

def.key <-  c( "esscom", "rentas", "sempadan", "laut",  "China", "selatan", "krisis",
               "antikeganasan", "border", "bomb", "bom", "south", "china", "sea", "pelampau",
               "extremist", "southern", "philippine", "militan", "militant", "threat", "sayyaf",
               "Moro", "southern", "thailand", "islamic", "state", "overlapping", "claimt", "arrested",
               "thailand", "indonesia", "Filipina", "daesh"
)
def.key <- cbind(word = def.key, kategori = "Keselamatan") %>% 
  as.data.frame()

crime.key <- c("samun", "curi", "steal", "culik", "kidnap", "rusuh",  "robber",  "rompak",
               "leweng",  "felon",  "senjata",  "violent", "suicide",  "bribe",  "rasuah",  "ditahan",
               "pecah", "amanah", "CBT", "drug", "dadah", "rape", "rogol", "abuse", "salah", "JSJ",
               "Kanun", "Keseksaan", "Siasatan", "Jenayah", "illegal","gambling", "judi", "haram", 
               "firearm", "senjata", "Antidadah",
               "fraud" , "SPRM", "MACC", "detain", "misappropriation")
crime.key <- cbind(word = crime.key, kategori = "Jenayah") %>% 
  as.data.frame()

imigr.key <- c("seludup", "penyeludupan", "rentas", "sempadan", "border", "confiscate",
               "imigresen", "immigrant", "rampas", "pendatang", "asing")
imigr.key <- cbind(word = imigr.key, kategori = "Rentas Sempadan") %>% 
  as.data.frame()

atm.key <- c("Tentera", "panglima", "ATM", "Armed Forces",
             "army", "navy ", "air force", "Hishammuddin",
             "Darat", "Laut", "Udara", "UNIFIL", "TLDM", "TUDM",
             "military", "soldier ", "rank", "regiment", "bekas",
             "brigade", "briged", "Malbatt", "Johari", "Baharum",
             "perajurit", "PVATM")
atm.key <- cbind(word = atm.key, kategori = "Rentas Sempadan") %>% 
  as.data.frame()

pol.key <- c(" BN ", "UMNO", "Se-Malaysia", "MCA", "Pakatan", "Harapan", "PKR",
             "MIC", "Keadilan", "democratic", "party", "Pribumi", "Bersatu",
             "Parti Gerakan", "MYPPP", "Parti Bangsa Bersatu (PBB)", "Parlimen",
             "SUPP", "Dewan", "Undangan",
             "PBRS", "UPKO", "SPDP", "PRS", "PCM", " PAN ", "PAS ", 
             "PBS", "DAP", "PPBM"
             )
pol.key <- cbind(word = pol.key, kategori = "Rentas Sempadan") %>% 
  as.data.frame()

pru.key <- c( "Suruhanjaya", "Pilihan", "Raya", "PRU", "daftar", "pemilih",
              "voter", "(EC)", "SPR",
              "general", "election", "undi", "vote")
pru.key <- cbind(word = pru.key, kategori = "Rentas Sempadan") %>% 
  as.data.frame()

dstr.key <- c("banjir", "flood", "fire", "kebakaran", "angin", "kencang", "kimia", "berbahaya",
              "runtuh", "slide", "rain", "wind", "taufan", "kebocoran",
              "Bomba", "toxic", "leak", "typhoon", "oil", "minyak", "collide")
dstr.key <- cbind(word = dstr.key, kategori = "Rentas Sempadan") %>% 
  as.data.frame()

cat.key <- rbind(def.key, crime.key, dstr.key, imigr.key, atm.key, pol.key, pru.key)

news.tidy <- news.today %>% 
  filter(src %in% news.eng) %>% 
  select(src, article) %>% 
  unnest_tokens(word, article)

news.stm <- news.tidy %>%
  inner_join(get_sentiments("bing")) %>%
  group_by(word) %>% 
  count(sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

news.tmy <- news.today %>% 
  filter(src %in% news.my) %>% 
  select(src, article) %>% 
  unnest_tokens(word, article)

news.smy <- news.tmy %>%
  inner_join(binmy) %>%
  group_by(word) %>% 
  count(sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

news.stm <- news.stm %>% 
  rbind(news.smy)

## @knitr daily.kpi
daily.kpi <- news.stm %>%
  left_join(cat.key) %>% 
  group_by(kategori) %>%
  summarise(KPI = mean(sentiment))

save.image(file = "newsDailyKPI.RData")

# Outer Keywords ----------------------------------------------------------

word.out <- news.stm %>%
  anti_join(cat.term) %>%
  #inner_join(crime.key) %>% 
  inner_join(def.key)

