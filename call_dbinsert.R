# call_dbinsert.R

# update db ----
con <- RMariaDB::dbConnect(RMariaDB::MariaDB(), username="abi", password="80907299",
                           dbname="news", host="abi-linode.name.my", port="3306")

# Run query to append table from dataframe
DBI::dbAppendTable(con,"text",df)
RMariaDB::dbDisconnect(con)

# connect mongo db ----
# This is the connection_string. You can get the exact url from your MongoDB cluster screen
# mongodb://[username:password@]host1[:port1][,...hostN[:portN]][/[defaultauthdb][?options]]
connection_string = 'mongodb://192.168.1.124'
db <- mongolite::mongo(collection="media", db="news", url=connection_string)

# insert doc ----
# Run query to append table from dataframe
db$insert(df)