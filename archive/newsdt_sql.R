# newsdt_sql.R
# run daily to append news DB
# start from 19 Okt 21

# init ----
library(data.table)
library(RMariaDB)
library(lubridate)

# read data files ----
con <- RMariaDB::dbConnect(RMariaDB::MariaDB(), username="abi", password="80907299",
                           dbname="news", host="abi-linode.name.my", port="3306")

# Run query to append table from dataframe
# res <- dbSendQuery(con, "SELECT CAST(datePub AS DATE) `pub` FROM text")
res <- dbSendQuery(con, "SELECT datePub,headlines,article FROM text")
df <- data.table::as.data.table(dbFetch(res))

#  disconnect db ----
RMariaDB::dbClearResult(res)
RMariaDB::dbDisconnect(con)

# save news db ----
save.image(file = "/newsdb/newsdb.RData")

# Summary 
# df %>% group_by(year(pub)) %>% count()
df[like(headlines,"1mdb",ignore.case = TRUE),c("datePub","headlines")]

