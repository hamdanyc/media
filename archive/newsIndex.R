# newsIndex.R

library(dplyr)
library(stringr)
load("newsdaily.RData")

# Init Text ---------------------------------------------------------------
def.key <-
  c(
    "ESSCOM", "rentas sempadan",
    "laut China selatan", "krisis di wilayah",
    "antikeganasan", "border",
    "south china sea", "pelampau", "extremist",
    "southern philippine", "militan", "militant",
    "threat of militant", "sayyaf",
    "Moro ", "southern thailand",
    "islamic state", "overlapping claimt",
    "militant arrested", "malaysia-thailand",
    "malaysia-indonesia", "malaysia-Filipina",
    "daesh"
  )

crime.key <- rbind( "bomb ", "bom ", "samun", "curi ", "steal",
                "culik",  "kidnap",  "rusuh",  "robber",  "rompak",
                "leweng",  "felon",  "senjata",  "violen",
                "suicide",  "bribe",  "rasuah",  "ditahan",
                "fraud" ,  "SPRM",  "MACC",  "detain",  "misappropriation")

imigr.key <- rbind("eludup", "rentas", "sempadan", "cross border", "confiscate",
               "imigresen", "immigrant", "rampas", "pendatang asing")

atm.key <- rbind("Angkatan Tentera Malaysia", "panglima", "ATM", "komander", "Malaysian Armed Forces",
             "Armed Forces", " army", " navy ", "air force", "Hishammuddin Hussein",
             "Tentera Darat", "Tentera Laut", "Tentera Udara", "UNIFIL", "TLDM", "TUDM",
             "military", "soldier ", "rank and file", "regiment", "bekas tentera",
             "brigade", "briged", "Malbatt", "menteri pertahanan", "Johari Baharum",
             "perajurit", "PVATM", "bekas anggota tentera")

pol.key <- rbind(" BN ", "UMNO", "Parti Islam Se-Malaysia", "MCA", "Pakatan Harapan", "PKR",
             "MIC", "Parti Keadilan", "democratic action party", "Parti Pribumi Bersatu Malaysia",
             "Parti Gerakan", "MYPPP", "Parti Bangsa Bersatu (PBB)", "Parlimen",
             "SUPP", "Pertubuhan Pribumi Perkasa Malaysia", "Dewan Undangan Negeri",
             "PBRS", "UPKO", "SPDP", "PRS", "PCM", " PAN ", "PAS ", "PBS", "DAP", "PPBM",
             "Parti Amanah Nasional", "HINDRAF")

pru.key <- rbind( "pilihan raya", "Suruhanjaya Pilihan Raya", "PRU", "daftar pemilih",
              "voter", " Election Commission (EC)", "SPR ",
              "general election", "undi pos", "postal vote")


dstr.key <- rbind("banjir kilat", "flash flood", "fire", "kebakaran", "anging kencang",
          "tanah runtuh", "land slide", "heavy rain", "strong wind", "taufan",
          "typhoon","oil spill", "tumpahan minyak", "collide")

def <- data.frame(word=def.key, kategori="Keselamatan")
crime <- data.frame(word=crime.key, kategori="Jenayah")
bdr <- data.frame(word=imigr.key, kategori="Rentas Sempadan")
atm <- data.frame(word=atm.key, kategori="Ketenteraan")
pol <- data.frame(word=pol.key, kategori="Politik")
pru <- data.frame(word=pru.key, kategori="Pilihan Raya")
dst <- data.frame(word=dstr.key, kategori="Bencana")

espn <- rbind(def,crime,bdr,atm,pol,pru,dst)

# Text Data Frame ---------------------------------------------------------

def.txt <- news.today %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi >>", newslink, sep=":")) %>% 
  filter(str_detect(article, paste(def.key, collapse = '|' ))) %>% 
  select(text)

crime.txt <- news.today %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi >>", newslink, sep=":")) %>% 
  filter(str_detect(text, paste(crime.key, collapse = '|' ))) %>% 
  select(text)

imigr.txt <- news.today %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi >>", newslink, sep=":")) %>%
  filter(str_detect(text, paste(imigr.key, collapse = '|' ))) %>% 
  select(text) 

atm.txt <- news.today %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi >>", newslink, sep=":")) %>%
  filter(str_detect(text, paste(atm.key, collapse = '|' ))) %>%  
  select(text)

pol.txt <- news.today %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi >>", newslink, sep=":")) %>%
  filter(str_detect(text, paste(pol.key, collapse = '|' ))) %>%  
  select(text) 

pru.txt <- news.today %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi >>", newslink, sep=":")) %>%
  filter(str_detect(text, paste(pru.key, collapse = '|' ))) %>%  
  select(text) 

dstr.txt <- news.today %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi >>", newslink, sep=":")) %>%
  filter(str_detect(text, paste(dstr, collapse = '|' ))) %>%  
  select(text) 

# Remove duplicate --------------------------------------------------------

def.txt <- def.txt %>%
  anti_join(crime.txt, imigr.txt, atm.txt, pol.txt, 
            pru.txt, dstr.txt, by = "text")
crime.txt <- crime.txt %>%
  anti_join(def.txt, imigr.txt, atm.txt, pol.txt, 
            pru.txt, dstr.txt, by = "text")
imigr.txt <- imigr.txt  %>% 
  anti_join(crime.txt, def.txt, atm.txt, pol.txt, 
            pru.txt, dstr.txt, by = "text")
atm.txt <- atm.txt %>%
  anti_join(imigr.txt, def.txt, crime.txt, dstr.txt, 
            pol.txt, pru.txt, by = "text")
pol.txt <- pol.txt %>%
  anti_join(imigr.txt, def.txt, crime.txt, dstr.txt, 
            atm.txt, pru.txt, by = "text")
pru.txt <- pru.txt %>%
  anti_join(imigr.txt, def.txt, crime.txt, dstr.txt, 
            atm.txt, pol.txt, by = "text")
dstr.txt <- dstr.txt %>%
  anti_join(imigr.txt, def.txt, crime.txt, atm.txt, 
            pol.txt, pru.txt, by = "text")
# Tag by Keyword -------------------------------------------------------

word.idx <- function(some.txt, some.key){
  for(i in 1:nrow(some.txt)){
  j <- regexpr(paste(some.key, collapse = '|' ), some.txt[i,]) 
  k <- attr(j,"match.length")
  x[i,1] <- j
  x[i,2] <- k
  x[i,3] <- substr(some.txt[i,],j,k+j)
  # tmp.txt[i] <- paste(substr(some.txt,1,j-1), ">>",substr(some.txt,j,35))
  }
  return(x)
}

# Tag the Article ---------------------------------------------------------

x <- matrix(0, nrow = nrow(def.txt), ncol = 3)
wx <- word.idx(def.txt, def.key)
def.txt <- def.txt %>%
  mutate(text = paste("**[Tag:", wx[,3], "]**", text))

x <- matrix(0, nrow = nrow(crime.txt), ncol = 3)
wx <- word.idx(crime.txt, crime.key)
crime.txt <- crime.txt %>%
  mutate(text = paste("**[Tag:", wx[,3], "]**", text))

x <- matrix(0, nrow = nrow(imigr.txt), ncol = 3)
wx <- word.idx(imigr.txt, imigr.key)
imigr.txt <- imigr.txt %>%
  mutate(text = paste("**[Tag:", wx[,3], "]**", text))

x <- matrix(0, nrow = nrow(atm.txt), ncol = 3)
wx <- word.idx(atm.txt, atm.key)
atm.txt <- atm.txt %>%
  mutate(text = paste("**[Tag:", wx[,3], "]**", text))

x <- matrix(0, nrow = nrow(pol.txt), ncol = 3)
wx <- word.idx(pol.txt, pol.key)
pol.txt <- pol.txt %>%
  mutate(text = paste("**[Tag:", wx[,3], "]**", text))

x <- matrix(0, nrow = nrow(pru.txt), ncol = 3)
wx <- word.idx(pru.txt, pru.key)
pru.txt <- pru.txt %>%
  mutate(text = paste("**[Tag:", wx[,3], "]**", text))

x <- matrix(0, nrow = nrow(dstr.txt), ncol = 3)
wx <- word.idx(dstr.txt, dstr)
dstr.txt <- dstr.txt %>%
  mutate(text = paste("**[Tag:", wx[,3], "]**", text))

# Facts Summaries ---------------------------------------------------------

articleBykategori <- rbind(atm.txt, crime.txt, def.txt, dstr.txt, imigr.txt, pol.txt, pru.txt)
