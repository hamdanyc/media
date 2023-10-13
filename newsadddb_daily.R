# newsadddb_daily.R
# run daily to append news DB
# start from 19 Okt 21

# init ----
library(dplyr)
library(RMariaDB)
load("newsdaily.RData")

# read data files ----
con <- RMariaDB::dbConnect(RMariaDB::MariaDB(), group = "linode")
# con1 <- RMariaDB::dbConnect(RMariaDB::MariaDB(), group = "pve")

# Run query to append table from dataframe
DBI::dbAppendTable(con,"text",news.today)
RMariaDB::dbDisconnect(con)
# DBI::dbAppendTable(con1,"text",news.today)
# RMariaDB::dbDisconnect(con1)
