# newsadddb_mongo.R
# run daily to append news DB
# start from 2 Jul 2022

# init ----
library(dplyr)
library(mongolite)
load("newsdaily.RData")

# connect db ----
# This is the connection_string. You can get the exact url from your MongoDB cluster screen
# mongodb://[username:password@]host1[:port1][,...hostN[:portN]][/[defaultauthdb][?options]]
# connection_string = readLines(con="~/media/.url.txt")
USER_ID <- Sys.getenv("USER_ID")
PASSWORD <- Sys.getenv("PASSWORD")
DB_SVR <- Sys.getenv("DB_SVR")
url <- paste0("mongodb://", USER_ID, ":", PASSWORD, "@", DB_SVR)
db <- mongo(collection="media", db="news", url=url)

# insert doc ----
# Run query to append table from dataframe
db$insert(news.today)


