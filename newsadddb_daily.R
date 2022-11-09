# newsadddb_daily.R
# run daily to append news DB
# start from 19 Okt 21

# init ----
library(dplyr)
load("newsdaily.RData")

# read data files ----
con <- RMariaDB::dbConnect(RMariaDB::MariaDB(), group = "my-db")
con1 <- RMariaDB::dbConnect(RMariaDB::MariaDB(), username="abi", password="80907299",
                           dbname="news", host="192.168.1.122", port="3306")

# Run query to append table from dataframe
DBI::dbAppendTable(con,"text",news.today)
DBI::dbAppendTable(con1,"text",news.today)
RMariaDB::dbDisconnect(con)
RMariaDB::dbDisconnect(con1)
