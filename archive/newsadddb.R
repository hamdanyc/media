# newsadddb.R
# run every month to append news DB
# start from Aug 21

# init ----
library(dplyr)

# read data files ----
con <- RMariaDB::dbConnect(RMariaDB::MariaDB(), username="abi", password="80907299",
                           dbname="news", host="abi-linode.name.my", port="3306")
on.exit(RMariaDB::dbDisconnect(con))

RMariaDB::dbGetQuery(con, "SELECT count(*) FROM text")
# RMariaDB::dbGetQuery(con, "SELECT src, headlines,COUNT(*) FROM text GROUP BY src,headlines HAVING COUNT(*) > 1")
# RMariaDB::dbGetQuery(con, "SELECT kategori,count(*) FROM text GROUP BY kategori")

# read from /data
mypath <- paste0(getwd(),"/data")
filenames <- list.files(path=mypath, pattern="*.txt", full.names=TRUE)
data <- lapply(filenames, function(x) readr::read_delim(x,"|"))
df_news <- data.table::rbindlist(data, fill = TRUE)

# clean-up df ----
thenews <- c("agendadaily",
             "airtimes",
             "astroawani",
             "beritaharian",
             "bernama",
             "borneopost",
             "dailyexpress",
             "fmt",
             "harakah",
             "hmetro",
             "keadilandaily",
             "kosmo",
             "malaysiadateline",
             "malaysiachronicle",
             "malaysiakini",
             "malaysiainsight",
             "nst",
             "roketkini",
             "sarawakvoice",
             "sinarharian",
             "sinchew",
             "theedge",
             "themalaymailonline",
             "theStar",
             "thesundaily",
             "umnoonline",
             "utusan")

df <- df_news %>% 
  filter(src %in% thenews) %>%
  filter(!is.na(headlines)) %>%
  filter(!is.na(article)) %>%
  filter(kategori %in% c("Bencana","Jenayah","Imigran","Politik","Sosio-Ekonomi","Keselamatan","Ketenteraan","Kewangan")) %>%
  distinct(src,datePub,headlines,newslink,article,kategori,negative,positive,sentiment,tag)

# Run query to append table from dataframe
DBI::dbAppendTable(con,"text",df)
RMariaDB::dbDisconnect(con)
