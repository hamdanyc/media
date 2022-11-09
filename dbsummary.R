# dbsummary.R
# run daily to append news DB
# start from 19 Okt 21

# init ----
library(dplyr)
library(DBI)

# read data files ----
con <- RMariaDB::dbConnect(RMariaDB::MariaDB(), username="abi", password="80907299",
                           dbname="news", host="abi-linode.name.my", port="3306")

# Run query to append table from dataframe
res <- dbSendQuery(con, "select src, headlines from text where datePub=current_date()")
df <- dbFetch(res)
df %>% group_by(src) %>% count()
count(df)

#  disconnect db ----
RMariaDB::dbDisconnect(con)
