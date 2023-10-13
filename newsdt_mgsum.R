# newsdt_mgsum.R

# init ----
library(data.table)
library(dplyr)
library(mongolite)

# connect db ----
# This is the connection_string. You can get the exact url from your MongoDB cluster screen
# mongodb://[username:password@]host1[:port1][,...hostN[:portN]][/[defaultauthdb][?options]]
connection_string = readLines(con=".url.txt")
db <- mongo(collection="media", db="news", url=connection_string)

# query today news ----
res <- db$find(fields = '{"datePub": 1}')
res$pub <- as.Date(res$datePub)
df <- data.table::as.data.table(res)

#  disconnect db ----
db$disconnect()

# Summary 
# df %>% group_by(year(pub)) %>% count()
df[,.N,year(pub)] %>% arrange(year)

# df %>% filter(year(pub) == 2021) %>% 
#   group_by(month(pub))  %>% 
#   count()
df[year(pub) == year(today()),.N,month(pub)]
df[year(pub) == year(today()) & month(pub) == month(today()),.N,day(pub)]
#dr[,.N,src]
# df %>% filter(pub == today()) %>% count()
df[,.N]

