# bernama.R

# Init ----
library(rvest)
library(dplyr)

# Read html ----
fu_bef <- "https://www.parlimen.gov.my/carian.html?page="
fu_aft <- "&ipp=30&documen%5B%5D=perbahasan&doctype%5B%5D=DN-hs&daterangeraw=09%2F09%2F2022+-+08%2F10%2F2022&DATETYPE=0&str2=&str=aset+pertahanan&uweb=dn&submit=CARI"
maxpage <- 5
urlink <- lapply(1:maxpage, function(i) {
  Sys.sleep(1)
  theNews <- read_html(paste0(fu_bef,i,fu_aft))
  theNews %>%
    html_elements("h3 a") %>%
    html_attr("href")
})

# Scrape page ----
hansard.lst <- paste0("'","https://www.parlimen.gov.my",unlist(urlink),"'")
write(hansard.lst,file = "hansard.txt")
