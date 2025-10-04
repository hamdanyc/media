# news_uploadb.R
# upload prev yr's news to DB

# init ----
library(dplyr)
load("news_cat.RData")

con <- RMariaDB::dbConnect(RMariaDB::MariaDB(), username="abi", password="80907299",
                           dbname="news", host="abi-linode.name.my", port="3306")

# Append table to db ----
db_load <- function(tb){
  df <- tb %>% 
    select(src,datePub,headlines,newslink,article,kategori,negative,positive,sentiment) %>% 
    mutate("tag" = "")
  DBI::dbAppendTable(con,"text",df)
}

# upload all data frame (dt1,dt2, ..., dt21)
# tb_lst <- c(dt2,dt3,dt4,dt5,dt6,dt7,dt8,dt9,dt10,
#          dt11,dt12,dt13,dt14,dt15,dt16,dt17,dt18,dt19,dt20,
#          dt21,dt22,dt23,dt24,dt25,dt26,dt27,dt28)
# for (tb in tb_lst) {
#   db_load(tb)
# } or
# sapply(tb_lst, function(x) db_load(x))

# db_load(dt1)
# db_load(dt2)
# db_load(dt3)
# db_load(dt4)
# db_load(dt5)
# db_load(dt6)
# db_load(dt7)
# db_load(dt8)
# db_load(dt9)
# db_load(dt10)
# db_load(dt11)
# db_load(dt12)
# db_load(dt13)
# db_load(dt14)
# db_load(dt15) # Error: Data too long for column 'article' at row 1 [1406]
# db_load(dt16)
# db_load(dt17)
# db_load(dt18)
# db_load(dt19)
# db_load(dt20)
# db_load(dt21)
# db_load(dt22)
# db_load(dt23)
# db_load(dt24)
# db_load(dt25)
# db_load(dt26)
# db_load(dt27)
# db_load(dt28)

RMariaDB::dbDisconnect(con)

