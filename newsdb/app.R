# app.R

# .libPaths(c("~/R/x86_64-pc-linux-gnu-library/3.6","/usr/local/lib/R/site-library"))

library(shiny)
library(mongolite)

# connect db ----
# This is the connection_string. You can get the exact url from your MongoDB cluster screen
# mongodb://[username:password@]host1[:port1][,...hostN[:portN]][/[defaultauthdb][?options]]
connection_string = readLines(con=".url.txt")
db <- mongo(collection="media", db="news", url=connection_string)

# query today news ----

ui <- fluidPage(
  checkboxInput("kyw", "by keyword?", FALSE),
  textInput("tkey", "Enter the keyword:", value = "%veteran%tentera%"),
  textInput("date1", "Date:", value = format(Sys.Date(),"%Y/%m/%d")),
  DT::dataTableOutput("tbl")
)

server <- function(input, output, session) {
  output$tbl <- DT::renderDataTable({
    query <- paste0('{ "datePub" : "',input$date1 , '"}')
    res <- db$find(query=query,fields = '{"_id": 0, "newslink": 0}',limit = 2500)
  }, options = list(searchHighlight = TRUE))
}

shinyApp(ui, server)