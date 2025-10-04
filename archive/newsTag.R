# newsTag.R
## @knitr sentiment
# data frame cat.key for MariaDB

# Init ----
library(stringr)
library(RTextTools)
library(dplyr)

load("newsdaily.RData")
load("binmy.RData")
load("news_model.RData")

# Define Keywords ----
def.key <-  c( "ESSCOM", "sempadan", "laut China selatan", "krisis di wilayah", "agensi kawalan", "sepanjang sempadan",
               "Eastern Sabah Security Zone", "sistem pemantauan", "pos kawalan", "AKSEM", "rentas sempadan", "threat",
               "antikeganasan", "cross border", "bomb ", "bom ", "south china sea", "pelampau", "ESSZONE", "pemerdagangan",
               "extremist", "southern philippines", "militan", "militant", "threat of militant", "sayyaf", "national security",
               "Moro ", "southern thailand", "islamic state", "overlapping claimt", "militant arrested", "terrorism",
               "malaysia-thailand", "malaysia-indonesia", "malaysia-filipina", "malaysia-philippines", "pencerobohan",
               "daesh", "pasukan keselamatan", "ketenteraman awam", "keganasan", "POTA", "negara jiran", "violent extremism")

crime.key <- c("samun", "mencuri", "steal", "culik", "kidnap", "rusuh",  "robber",  "rompak", "JSJ", "jenayah", "pecah rumah",
               "seleweng",  "felon",  "senjata",  "violent", "suicide",  "bribe",  "rasuah",  "ditahan", "diberkas", "dicuri",
               "pecah amanah", "CBT", "drug", "dadah", " rape", "rogol", "abuse", "salah guna", "JSJ", "bersenjatakan",
               "Kanun Keseksaan", "Jabatan Siasatan Jenayah", "illegal", "gambling", "judi ", "AADK",
               "firearm", "senjata api", "Agensi Antidadah Kebangsaan", "porno", "fidopile", "arson", "pemerasan",
               "crimes", "human trafficking", "racket", "perpetrators", "combating", "cctvs", "incidents",
               "fraud" , "SPRM", "MACC", "detain", "misappropriation", "paedophile", "ajaran sesat")

imigr.key <- c("seludup", "rentas", "sempadan", "cross border", "confiscate", "smuggle",
               "imigresen", "immigrant", "rampas", "pendatang asing", "warga asing",
               "pasport", "kastam", "ICQS", "NADMA")

atm.key <- c("Angkatan Tentera Malaysia", "Malaysian Armed Forces", "mindef","MAWILLA",
             "Armed Forces", "army", "navy", "air force", "LTAT", "rejimen", "Liew Chin Tong",
             "Tentera Darat", "Tentera Laut", "Tentera Udara", "UNIFIL", "TLDM", "TUDM",
             "military", "soldier ", "rank and file", "regiment", "bekas tentera", "RKAT",
             "brigade", "briged", "MALBATT", "Menteri Pertahanan", "Defense Minister", "tentera ",
             "perajurit", "PVATM", "Majlis Angkatan Tentera", "bekas anggota tentera")

pol.key <- c(" BN ", "UMNO", "Parti Islam Se-Malaysia", "MCA", "Pakatan Harapan", "PKR",
             "MIC", "Parti Keadilan", "democratic action party", "Parti Pribumi Bersatu Malaysia",
             "Parti Gerakan", "MYPPP", "Parti Bangsa Bersatu (PBB)", "anwarisme", "politik kepartian",
             "SUPP", "Pertubuhan Pribumi Perkasa Malaysia", "politik", "politics",
             "PBRS", "UPKO", "SPDP", "PRS", "PCM", " PAN ", "PAS ", "PBS", "DAP", "PPBM", "PH",
             "Parti Amanah Nasional", "HINDRAF")

soe.key <- c("sosial", "masyarakat", "pemerkasaan ekonomi", "kesukarelawanan", "ETP", "ekonomi",
             "kesejahteraan", "modal insan", "memperkasa", "kerohanian", "masyarakat majmuk",
             "pendidikan", "usahawan","justice4adib")

# pru.key <- c( "pilihan raya", "Suruhanjaya Pilihan Raya", "PRU", "daftar pemilih", "politician",
#               "voter", " Election Commission (EC)", "SPR ", "Parlimen", "Dewan Undangan Negeri",
#               "general election", "undi pos", "postal vote")

dstr.key <- c("banjir kilat", "flash flood", "rescue department", "kebakaran", "anging kencang", "blaze",
              "bencana alam", "bantuan kemanusiaan", "tragedi", "kehilangan nyawa", "perubahan iklim", "firemen",
              "kimia   berbahaya", "tanah runtuh", "land slide", "heavy rain", "strong wind", "razed",
              "taufan", "kebocoran gas", "bencana", "Jabatan Bomba dan Penyelamat Malaysia", "burnt",
              "NADMA", "Angkatan Pertahanan Awam", "mishap", "toxic gas", "gas leak", "distress call",
              "typhoon", "oil spill", "tumpahan minyak", "collide", "disaster", "alerted")

# Source Sentiment ----
# output news.stm

source("newsSetmnt.R")

# tag by Categories ----
# predict 

new_data <- news.today
n <- nrow(news.today)
pred_mat <- create_matrix(new_data$article, originalMatrix = matrix, removeNumbers=TRUE,
                          stemWords=FALSE, weighting=tm::weightTfIdf)
pred_cont <- create_container(pred_mat,labels = rep("",n), testSize = 1:n, virgin=FALSE)
pred_df <- classify_model(pred_cont,model)

news.today <- mutate(news.today,kategori = pred_df$SVM_LABEL)

def.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>%
  filter(kategori == "Keselamatan") %>% 
  mutate(tag = str_match(article, paste(def.key, collapse = '|' ))[,1])

crime.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(kategori == "Jenayah") %>% 
  mutate(tag = str_match(article, paste(crime.key, collapse = '|' ))[,1])

imigr.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(kategori == "Imigran") %>% 
  mutate(tag = str_match(article, paste(imigr.key, collapse = '|' ))[,1])

atm.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(kategori == "Ketenteraan") %>% 
  mutate(tag = str_match(article, paste(atm.key, collapse = '|' ))[,1])

pol.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(kategori == "Politik") %>% 
  mutate(tag = str_match(article, paste(pol.key, collapse = '|' ))[,1])

soe.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(kategori == "Sosio-Ekonomi") %>% 
  mutate(tag = str_match(article, paste(soe.key, collapse = '|' ))[,1])

fin.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(kategori == "Kewangan") %>% 
  mutate(tag = str_match(article, paste(soe.key, collapse = '|' ))[,1])

dstr.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  filter(kategori == "Bencana") %>% 
  mutate(tag = str_match(article, paste(dstr.key, collapse = '|' ))[,1])

# Remove Duplicates ----
def.txt <- def.txt %>%
  anti_join(imigr.txt, by = "headlines")
def.txt <- def.txt %>%
  anti_join(atm.txt, by = "headlines")
def.txt <- def.txt %>%
  anti_join(pol.txt, by = "headlines")
crime.txt <- crime.txt %>%
  anti_join(imigr.txt, by = "headlines")
crime.txt <- crime.txt %>%
  anti_join(pol.txt, by = "headlines")
imigr.txt <- imigr.txt  %>%
  anti_join(atm.txt, by = "headlines")
atm.txt <- atm.txt %>%
  anti_join(dstr.txt, by = "headlines")
atm.txt <- atm.txt %>%
  anti_join(crime.txt, by = "headlines")
atm.txt <- atm.txt %>%
  anti_join(pol.txt, by = "headlines")
pol.txt <- pol.txt %>%
  anti_join(soe.txt, by = "headlines")
dstr.txt <- dstr.txt %>%
  anti_join(crime.txt, by = "headlines")

# Calc Sentiment Index ----
cat.key <- dplyr::bind_rows(def.txt, crime.txt, dstr.txt, imigr.txt, atm.txt, pol.txt, soe.txt, fin.txt)

## @knitr daily.isentiment
daily.kpi <- news.stm %>%
  left_join(cat.key, by = "headlines") %>% 
  group_by(kategori) %>% 
  summarise(indeks = sum(sentiment.x), cnt = n())

# Aggregate daily isentiment ----
daily.idx <- daily.kpi %>%
  group_by(kategori) %>%
  summarise(indeks = round(sum(indeks, na.rm=T),1))
  #summarise(indeks = round(mean(indeks, na.rm=T)*10,1))

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

# Save & write to DB/file ----
datePub <- format(Sys.time(),"%d_%b_%y",tz="Asia/Kuala_Lumpur")
save(daily.idx, daily.kpi, news.stm, cat.key, pol.key, crime.key,
     imigr.key, atm.key, soe.key, dstr.key, def.key,
     file = "newsDailyKPI.RData")
# ceased on 19 Okt 21
# tgt <- paste("data/",datePub,"_news.txt", sep = "")
# cat.key %>%
#   write.table(file = tgt, row.names = FALSE, sep = "|", quote=FALSE, append = TRUE)


