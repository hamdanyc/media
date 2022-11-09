# newsClipPrep.R

library(dplyr)
library(stringr)

load("newsArticles.RData")
load("daily.RData")
options(digits=3)

def.key <-
  c(
    "esscom", "rentas sempadan",
    "laut China selatan", "krisis di wilayah",
    "antikeganasan", "border",
    "south china sea",
    "southern philippine", "militan", "militant",
    "threat of militant", "sayyaf",
    "Moro ", "southern thailand",
    "islamic state", "overlapping claimt",
    "militant arrested", "malaysia-thailand",
    "malaysia-indonesia", "malaysia-Filipina",
    "daesh"
  )

crime.key <- c("bomb ", "bom ", "culik", "kidnap", "rusuh", "robber", "rompak",
               "felon", "senjata", "violen", "suicide", "bribe", "rasuah", "tahan",
               "fraud" , "sprm", "macc", "detain", "misappropriation")

imigr.key <- c("eludup", "rentas", "sempadan", "cross border", 
               "imigresen", "immigrant", "rampas")

atm.key <- c("angkatan tentera", "panglima", " atm ",
             "armed forces", " army ", " navy ", "air force",
             "tentera darat", "tentera laut", "tentera udara",
             "military", "soldier ", "rank and file", "regiment",
             "brigade", "briged",
             "perajurit", "pvatm", "bekas tentera")

pol.key <- c(" bn ", "umno", "Parti Islam Se-Malaysia", " mca ", " pakatan harapan ",
             "pilihan raya", " mic ", " pkr ", " dap ", " ppbm ",
             "parti gerakan", " myppp ", " pbb ", " supp ", " pbs ",
             " pbrs ", " upko ", " spdp ", " prs ", " pcm ",
             "parti amanah nasional", " parlimen ", "hindraf")

def.txt <- article.all %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi >>", newslink, sep=":")) %>% 
  filter(str_detect(article, paste(def.key, collapse = '|' ))) %>% 
  select(text)

crime.txt <- article.all %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi >>", newslink, sep=":")) %>% 
  filter(str_detect(article, paste(crime.key, collapse = '|' ))) %>% 
  select(text)

imigr.txt <- article.all %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi >>", newslink, sep=":")) %>% 
  filter(str_detect(article, paste(imigr.key, collapse = '|' ))) %>% 
  select(text)

atm.txt <- article.all %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi >>", newslink, sep=":")) %>% 
  filter(str_detect(article, paste(atm.key, collapse = '|' ))) %>% 
  select(text)

pol.txt <- article.all %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi >>", newslink, sep=":")) %>% 
  filter(str_detect(article, paste(pol.key, collapse = '|' ))) %>% 
  select(text)

tbl.tmp <- rbind(def.txt, crime.txt, imigr.txt, atm.txt, pol.txt)

article.comb <- unique(tbl.tmp)
article.done <- article.comb
save(file="daily.RData", article.done)