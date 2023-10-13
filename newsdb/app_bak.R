# app.R

# .libPaths(c("~/R/x86_64-pc-linux-gnu-library/3.6","/usr/local/lib/R/site-library"))

library(shiny)
library(DBI)
library(pool)

# connect db
pool <- dbPool(
  drv = RMySQL::MySQL(),
  dbname = "news",
  host = "abi-linode.name.my",
  username = "abi",
  password = "80907299"
)

ui <- fluidPage(
  checkboxInput("kyw", "by keyword?", TRUE),
  textInput("tkey", "Enter the keyword:", value = "%veteran%tentera%"),
  textInput("date1", "Date:", value = format(Sys.Date(),"%Y/%m/%d")),
  DT::dataTableOutput("tbl")
)

server <- function(input, output, session) {
  output$tbl <- DT::renderDataTable({
    if (input$kyw == TRUE) sql <- "SELECT src,datepub,headlines,article FROM text WHERE headlines LIKE ?tkey LIMIT 2500;"
    else sql <- "SELECT src,datepub,headlines,article FROM text WHERE datepub = ?tkey LIMIT 2500;"
    if (input$kyw == TRUE) query <- sqlInterpolate(pool, sql, tkey = input$tkey)
    else query <- sqlInterpolate(pool, sql, tkey = input$date1)
    dbGetQuery(pool, query)
  }, options = list(searchHighlight = TRUE))
}

shinyApp(ui, server)