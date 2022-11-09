# newsdb_sum.R
# run daily to append news DB
# start from 19 Okt 21

# init ----
library(dplyr)
library(RMariaDB)
library(lubridate)

# read data files ----
con <- RMariaDB::dbConnect(RMariaDB::MariaDB(), username="abi", password="80907299",
                           dbname="news", host="abi-linode.name.my", port="3306")

# Run query to append table from dataframe
res <- dbSendQuery(con, "SELECT CAST(datePub AS DATE) `pub` FROM text")
df <- dbFetch(res)

#  disconnect db ----
RMariaDB::dbClearResult(res)
RMariaDB::dbDisconnect(con)

# Summary 
df %>% group_by(year(pub)) %>% count()
df %>% filter(year(pub) == 2021) %>% 
  group_by(month(pub))  %>% 
  count()
df %>% filter(pub == today()) %>% count()


