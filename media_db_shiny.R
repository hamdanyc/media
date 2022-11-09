# iso_db_shiny.R

.libPaths(c("~/R/x86_64-pc-linux-gnu-library/3.6","/usr/local/lib/R/site-library"))

library(shiny)
library(DBI)
library(pool)

pool <- dbPool(
  drv = RMySQL::MySQL(),
  dbname = "news",
  host = "abi-linode.name.my",
  username = "abi",
  password = "80907299"
)

ui <- fluidPage(
  textInput("tkey", "Enter the keyword:", value = "%mdb%"),
  DT::dataTableOutput("tbl")
)

server <- function(input, output, session) {
    output$tbl <- DT::renderDataTable({
    sql <- "SELECT src,datepub,headlines,article FROM text WHERE headlines LIKE ?tkey;"
    query <- sqlInterpolate(pool, sql, tkey = input$tkey)
    dbGetQuery(pool, query)
  })
  
  # output$tbl <- renderTable({
  #   conn <- dbConnect(
  #     drv = RMySQL::MySQL(),
  #     dbname = "news",
  #     host = "abi-linode.name.my",
  #     username = "abi",
  #     password = "80907299")
  #   on.exit(dbDisconnect(conn), add = TRUE)
  #   dbGetQuery(conn, paste0(
  #     "SELECT article FROM text WHERE article LIKE ", input$tkey, ";"))
  # })
}

shinyApp(ui, server)