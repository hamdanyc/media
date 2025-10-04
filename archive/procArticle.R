# procArticle.R

def.key <-
  c(
    "esscom", "rentas sempadan",
    "laut China selatan", "krisis di wilayah",
    "antikeganasan", "border",
    "sempadan", "south china sea",
    "southern philippine", "militan", "militant",
    "threat of militant", "sayyaf",
    "Moro ", "southern thailand",
    "islamic state", "overlapping claimt",
    "militant arrested", "malaysia-thailand",
    "malaysia-indonesia", "malaysia-Filipina",
    "daesh"
  )

def.term <- data.frame(perkara="Keselamatan", keywords=def.key)

crime.key <- c("bomb ", "bom ", "culik", "kidnap", "rusuh", "robbery", "rompak",
               "arm", "senjata", "violent", "suicide")
imigr.key <- c("eludup", "rentas", "sempadan", "cross border", "immigrant", "rampas")

# act.term <- data.frame(perkara="Aktiviti", keywords=act.key)

atm.key <- c("angkatan tentera", "panglima", " atm ",
             "armed forces", " army ", " navy ", "air force",
             "tentera darat", "tentera laut", "tentera udara",
             "military", "soldier ", "rank and file",
             "brigade", "briged",
             "perajurit", "pvatm", "bekas tentera")

atm.term <- data.frame(perkara="ATM", keywords=atm.key)

# cat.keys <- c(def.key, act.key, atm.key)

def.txt <- article.all %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi", newslink, sep=":")) %>% 
  filter(str_detect(article, paste(def.key, collapse = '|' ))) %>% 
  select(text)

crime.txt <- article.all %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi", newslink, sep=":")) %>% 
  filter(str_detect(article, paste(crime.key, collapse = '|' ))) %>% 
  select(text)

imigr.txt <- article.all %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi", newslink, sep=":")) %>% 
  filter(str_detect(article, paste(imigr.key, collapse = '|' ))) %>% 
  select(text)

atm.txt <- article.all %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi", newslink, sep=":")) %>% 
  filter(str_detect(article, paste(atm.key, collapse = '|' ))) %>% 
  select(text)

tbl.tmp <- rbind(def.txt, crime.txt, imigr.txt, atm.txt)

article.comb <- unique(tbl.tmp)
