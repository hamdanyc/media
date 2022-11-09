# newsDailyKPIver1.R
## @knitr sentiment

library(tidytext)
library(tidyr)
library(stringr)

load("newsdaily.RData")
load("binmy.RData")
load("media.RData")

news.eng <- c("nst", "thestar", "theedge", "dailyexpress",
              "malaysiandigest", "sinchew","themalaymailonline", "thesundaily",
              "borneopost", "fmt", "selangortimes")
news.my <- c("agendadaily", "amanahdaily", "antarapos", "astroawani", "amanahdaily", "beritaharian",
             "bernama", "harakah", "hmetro", "keadilandaily", "hmetro", "kosmo", "malaysiadateline", 
             "malaysiakini", "roketkini", "sinarharian", "umnoonline", "utusan")

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
  mutate(kpi = sentiment) %>% 
  select(headlines, kpi)
def.kpi <- cbind(kategori="Keselamatan", def.kpi)

crime.kpi <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(str_detect(article, paste(crime.key, collapse = '|' ))) %>%
  mutate(kpi = sentiment) %>% 
  select(headlines, kpi)
crime.kpi <- cbind(kategori="Jenayah", crime.kpi)

imigr.kpi <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(str_detect(article, paste(imigr.key, collapse = '|' ))) %>%
  mutate(kpi = sentiment) %>% 
  select(headlines, kpi)
imigr.kpi <- cbind(kategori="Rentas Sempadan", imigr.kpi)

atm.kpi <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(str_detect(article, paste(atm.key, collapse = '|' ))) %>%
  mutate(kpi = sentiment) %>% 
  select(headlines, kpi)
atm.kpi <- cbind(kategori="Ketenteraan", atm.kpi)

pol.kpi <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(str_detect(article, paste(pol.key, collapse = '|' ))) %>%
  mutate(kpi = sentiment) %>% 
  select(headlines, kpi)
pol.kpi <- cbind(kategori="Politik", pol.kpi)

pru.kpi <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(str_detect(article, paste(pru.key, collapse = '|' ))) %>%
  mutate(kpi = sentiment) %>% 
  select(headlines, kpi)
pru.kpi <- cbind(kategori="Pilihan Raya", pru.kpi)

dstr.kpi <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(str_detect(article, paste(dstr.key, collapse = '|' ))) %>%
  mutate(kpi = sentiment) %>% 
  select(headlines, kpi)
dstr.kpi <- cbind(kategori="Bencana", dstr.kpi)

daily.kpi <- rbind(def.kpi, crime.kpi, imigr.kpi, atm.kpi, pol.kpi, pru.kpi, dstr.kpi)
daily.kpi <- na.omit(daily.kpi)

# Aggregate daily KPI ----------------------------------------------------------

daily.idx <- daily.kpi %>%
  group_by(kategori) %>%
  summarise(indeks = round(mean(kpi, na.rm=T)*10,1))

# Tranform polar to +ve

tform <- function(x){
  if(abs(x) < 50) {
    if(x < 0) x = 50 + x
  }
  else {
    if (x < 0) {x = 50 + x}
  }
  
  return(abs(x))
}

# daily.txt <- apply(daily.idx[,2], 1, function(x) tform(x))

# Save & write to file ---------------------------------------------------------------

datePub <- format(Sys.Date(), "%Y/%m/%d")
daily.txt <- data.frame(Tarikh=datePub, kategori=daily.idx$kategori, indeks=daily.idx$indeks)
daily.txt %>%
  write.table(file="kpi.csv", row.names = FALSE, fileEncoding = "ASCII",
              sep = "|", quote=FALSE)

save(daily.idx, daily.kpi, news.stm, file = "newsDailyKPI.RData")
