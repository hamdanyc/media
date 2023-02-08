# newsdb_sum.R
# run daily to append news DB
# start from 19 Okt 21

# init ----
library(data.table)
library(RMariaDB)
library(lubridate)

# read data files ----
# Run query to append table from dataframe
con <- RMariaDB::dbConnect(RMariaDB::MariaDB(), group = "linode")
res <- RMariaDB::dbSendQuery(con, "SELECT CAST(datePub AS DATE) `pub` FROM text")
df <- data.table::as.data.table(RMariaDB::dbFetch(res))
# Connect to my-db as defined in ~/.my.cnf
# con <- dbConnect(RMariaDB::MariaDB(), group = "my-db")
RMariaDB::dbClearResult(res)

# query today news ----
rs <- RMariaDB::dbSendQuery(con, "SELECT CAST(datePub AS DATE) `pub`, src FROM text WHERE datepub = CURDATE()")
dr <- data.table::as.data.table(RMariaDB::dbFetch(rs))

#  disconnect db ----
RMariaDB::dbClearResult(rs)
RMariaDB::dbDisconnect(con)

# Summary 
# df %>% group_by(year(pub)) %>% count()
df[,.N,year(pub)]
# df %>% filter(year(pub) == 2021) %>% 
#   group_by(month(pub))  %>% 
#   count()
df[year(pub) == year(today()),.N,month(pub)]
df[year(pub) == year(today()) & month(pub) == month(today()),.N,day(pub)]
dr[,.N,src]
# df %>% filter(pub == today()) %>% count()
df[,.N]
