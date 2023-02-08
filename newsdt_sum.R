# newsdb_sum.R
# run daily to append news DB
# start from 19 Okt 21

# init ----
library(data.table)
library(RMariaDB)
library(lubridate)

# read data files ----
con <- RMariaDB::dbConnect(RMariaDB::MariaDB(), group = "linode")
# Connect to my-db as defined in ~/.my.cnf
# con <- dbConnect(RMariaDB::MariaDB(), group = "my-db")

# Run query to append table from dataframe
res <- RMariaDB::dbSendQuery(con, "SELECT CAST(datePub AS DATE) `pub`, src FROM text")
df <- data.table::as.data.table(RMariaDB::dbFetch(res))

#  disconnect db ----
RMariaDB::dbClearResult(res)
RMariaDB::dbDisconnect(con)

# Summary 
# df %>% group_by(year(pub)) %>% count()
df[,.N,year(pub)]
# df %>% filter(year(pub) == 2021) %>% 
#   group_by(month(pub))  %>% 
#   count()
df[year(pub) == year(today()),.N,month(pub)]
df[year(pub) == year(today()) & month(pub) == month(today()),.N,day(pub)]
df[pub == today(),.N,src]
# df %>% filter(pub == today()) %>% count()
df[,.N]
