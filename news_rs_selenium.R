# news_rs_part.R

# server rselenium ----
remDr <- RSelenium::remoteDriver(remoteServerAddr = "192.168.1.126",
                                 port = 4444L,
                                 browserName = "firefox")

remDr$open()

rsnews <- c("agendadaily",
             "astroawani",
             "beritaharian",
             "hmetro",
             "nst",
             "thestar")

n <- 0
for (i in rsnews) {
  cat(i,fill = TRUE,sep = " ")
  try(source(paste0(i,".R")),
      silent=TRUE)
}

# close rselenium server----
remDr$close()
remDr$closeServer()
