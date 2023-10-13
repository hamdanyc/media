# app.R

library(DT)
# library(data.table)
load("newsdb.RData")

ui <- basicPage(
    textInput("keyword", label = "Keyword", value = "sprm"),
    h2("The News"),
    DT::dataTableOutput("mytable")
)

server <- function(input, output) {
    kw <- reactive({ input$keyword })
    output$mytable = DT::renderDataTable({
        # df[data.table::like(headlines,kw(),ignore.case = TRUE),c("datePub","headlines","article")]
        df[grepl(kw(), df$headlines, ignore.case = TRUE),c("datePub","headlines","article")]
    })
}

shinyApp(ui, server)