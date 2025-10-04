# tagIndex.R

library(dplyr)
library(stringr)
library(kableExtra)
library(knitr)

load("daily.RData")
load("newsdaily.RData") # news.today from newsdailyBat.R
load("newsDailyKPI.RData")

options(knitr.table.format = "html") 

# Define Keyword--------------------------------------------------------------

def.key <-  c( "ESSCOM", "rentas sempadan", "laut China selatan", "krisis di wilayah",
               "antikeganasan", "border", "bomb ", "bom ", "south china sea", "pelampau",
               "extremist", "southern philippine", "militan", "militant", "threat of militant", "sayyaf",
               "Moro ", "southern thailand", "islamic state", "overlapping claimt", "militant arrested",
               "malaysia-thailand", "malaysia-indonesia", "malaysia-Filipina",
               "daesh"
)

crime.key <- c("samun", "curi ", "steal", "culik", "kidnap", "rusuh",  "robber",  "rompak",
               "seleweng",  "felon",  "senjata",  "violen", "suicide",  "bribe",  "rasuah",  "ditahan",
               "pecah amanah", "CBT", "drug", "dadah", "rape", "rogol", "abuse", "salah guna", "JSJ",
               "Kanun Keseksaan", "Jabatan Siasatan Jenayah", "illegal gambling", "judi haram", 
               "firearm", "senjata api", "Agensi Antidadah Kebangsaan", "porno", "filopedia", "arson",
               "fraud" , "SPRM", "MACC", "detain", "misappropriation")

imigr.key <- c("seludup", "rentas", "sempadan", "cross border", "confiscate", "smuggle",
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


# Text DF -----------------------------------------------------------------

def.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  mutate(text = paste("**[Indeks ", sentiment, "]**", src, "**", headlines, "**", 
                      strtrim(article, 700),"... lagi >>", newslink, sep=":")) %>% 
  filter(str_detect(article, paste(def.key, collapse = '|' ))) %>% 
  select(text)

crime.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  mutate(text = paste("**[Indeks ", sentiment, "]**", src, "**", headlines, "**", 
                      strtrim(article, 700),"... lagi >>", newslink, sep=":")) %>% 
  filter(str_detect(article, paste(crime.key, collapse = '|' ))) %>% 
  select(text)

imigr.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  mutate(text = paste("**[Indeks ", sentiment, "]**", src, "**", headlines, "**", 
                      strtrim(article, 700),"... lagi >>", newslink, sep=":")) %>%
  filter(str_detect(article, paste(imigr.key, collapse = '|' ))) %>% 
  select(text) 

atm.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  mutate(text = paste("**[Indeks ", sentiment, "]**", src, "**", headlines, "**",
                      strtrim(article, 700),"... lagi >>", newslink, sep=":")) %>%
  filter(str_detect(article, paste(atm.key, collapse = '|' ))) %>%  
  select(text)

pol.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  mutate(text = paste("**[Indeks ", sentiment, "]**", src, "**", headlines, "**",
                      strtrim(article, 700),"... lagi >>", newslink, sep=":")) %>%
  filter(str_detect(article, paste(pol.key, collapse = '|' ))) %>%  
  select(text) 

pru.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  mutate(text = paste("**[Indeks ", sentiment, "]**", src, "**", headlines, "**",
                      strtrim(article, 700),"... lagi >>", newslink, sep=":")) %>%
  filter(str_detect(article, paste(pru.key, collapse = '|' ))) %>%  
  select(text) 

dstr.txt <- news.today %>%
  left_join(news.stm, by = "headlines") %>% 
  mutate(text = paste("**[Indeks ", sentiment, "]**", src, "**", headlines, "**",
                      strtrim(article, 700),"... lagi >>", newslink, sep=":")) %>%
  filter(str_detect(article, paste(dstr.key, collapse = '|' ))) %>%  
  select(text) 

# Function word.idx -------------------------------------------------------

word.idx <- function(src.txt, src.key){
    tag <- c("")
    txt <- c("")
    for(i in 1:nrow(src.txt)){
      tx <- str_extract(src.txt[i,], paste(src.key, collapse = '|' ))
      try(
        if (!is.na(tx)) {
          tag[i] <- paste("**[Tag:", tx, "]**", src.txt[i,], collapse = "\\n")
        }
      )
    }
    return(tag)
  }

# Tag Article -------------------------------------------------------------

def.tag <- as.data.frame(word.idx(def.txt, def.key), stringsAsFactors = F)
crime.tag <- as.data.frame(word.idx(crime.txt, crime.key), stringsAsFactors = F)
dstr.tag <- as.data.frame(word.idx(dstr.txt, dstr.key), stringsAsFactors = F)
imigr.tag <- as.data.frame(word.idx(imigr.txt, imigr.key), stringsAsFactors = F)
atm.tag <- as.data.frame(word.idx(atm.txt, atm.key), stringsAsFactors = F)
pol.tag <- as.data.frame(word.idx(pol.txt, pol.key), stringsAsFactors = F)
pru.tag <- as.data.frame(word.idx(pru.txt, pru.key), stringsAsFactors = F)

def.tag %>% 
  filter(df != "0") %>%
  kable() %>% 
  kable_styling(bootstrap_options = c("striped", "hover"))

