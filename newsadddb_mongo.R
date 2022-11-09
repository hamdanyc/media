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
connection_string = readLines(con=".url.txt")
db <- mongo(collection="media", db="news", url=connection_string)

# insert doc ----
# Run query to append table from dataframe
db$insert(news.today)


