# newsadddb_mongo.R
# run daily to append news DB
# start from 2 Jul 2022

# init ----
library(dplyr)
library(mongolite)
# load("/home/rstudio/media/newsdaily.RData") | expunged

# connect db ----
uri <- Sys.getenv("URI")
db <- mongo(collection="media", db="news", url=uri)

# insert newsdaily.RData.RData ----
# Run query to append table from dataframe
db$insert(news.today)

#  disconnect db ----
db$disconnect()





