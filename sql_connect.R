# sql_connect.R

library(RMariaDB)

con <- RMariaDB::dbConnect(RMariaDB::MariaDB(), username="rs", password="080460",
                 dbname="qms")
on.exit(RMariaDB::dbDisconnect(con))

# Run query to get results as dataframe
RMariaDB::dbGetQuery(con, "SHOW TABLES")
RMariaDB::dbGetQuery(con, "SELECT * FROM item")
