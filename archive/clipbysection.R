
def.key <- c("esscom", "rentas sempadan", "laut China selatan", "krisis di wilayah", "antikeganasan",
             "border", "sempadan", "south china sea", "southern philippine", "threat of militant", "Moro ",
             "southern thailand", " islamic state ", "overlapping claimt", "militant arrested",
             "malaysia-thailand", "malaysia-indonesia", "malaysia-Filipina", "daesh")

def.term <- data.frame(perkara="Keselamatan", keywords=def.key)

act.key <- c("rentas sempadan", "cross border", "eludup", "bomb ", "bom ",
             "militan", "culik", "kidnap", "rusuh", "immigrant")

act.term <- data.frame(perkara="Aktiviti", keywords=act.key)

atm.key <- c(" angkatan tentera ", " panglima ", " atm ",
             " armed forces ", " army ", " navy ", " airforce ",
             " tentera darat ", " tentera laut ", " tentera udara ",
             " military ", " soldier ", " rank and file ",
             " brigade ", " briged ",
             " perajurit ", " pvatm ", " bekas tentera ")

atm.term <- data.frame(perkara="ATM", keywords=atm.key)

cat.keys <- paste(def.key, act.key, atm.key, sep=",")

teks <- article.all %>%
  mutate(text = paste(src, "**", headlines, "**",
                      strtrim(article, 650),"... lagi", newslink, sep=":")) %>% 
  filter(str_detect(article, paste(def.key, collapse = '|' )))

