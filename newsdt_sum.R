# newsdb_sum.R
# run daily to append news DB
# start from 19 Okt 21

# init ----
library(data.table)
library(lubridate)

# read data files ----
# Connect to my-db as defined in ~/.my.cnf
# con <- dbConnect(RMariaDB::MariaDB(), group = "my-db")
con <- RMariaDB::dbConnect(RMariaDB::MariaDB(), group = "linode")

# query today news ----
res <- RMariaDB::dbSendQuery(con, "SELECT CAST(datePub AS DATE) `pub` FROM text")
df <- data.table::as.data.table(RMariaDB::dbFetch(res))
RMariaDB::dbClearResult(res)

# rs <- RMariaDB::dbSendQuery(con, "SELECT CAST(datePub AS DATE) `pub`, src FROM text WHERE datepub = CURDATE()")
# dr <- data.table::as.data.table(RMariaDB::dbFetch(rs))
# RMariaDB::dbClearResult(rs)

#  disconnect db ----
RMariaDB::dbDisconnect(con)

# Summary 
# df %>% group_by(year(pub)) %>% count()
df[,.N,year(pub)]

# df %>% filter(year(pub) == 2021) %>% 
#   group_by(month(pub))  %>% 
#   count()
df[year(pub) == year(today()),.N,month(pub)]
df[year(pub) == year(today()) & month(pub) == month(today()),.N,day(pub)]
#dr[,.N,src]
# df %>% filter(pub == today()) %>% count()
df[,.N]
