# news_rs_part.R

# server rselenium ----
remDr <- RSelenium::remoteDriver(remoteServerAddr = "172.17.0.2",
                                 port = 4444L,
                                 browserName = "firefox")

remDr$open()

rsnews <- c("agendadaily",
             "beritaharian",
             "hmetro",
             "nst",
             "thestar",
            "astroawani")

n <- 0
for (i in rsnews) {
  cat(i,fill = TRUE,sep = " ")
  try(source(paste0(i,".R")),
      silent=TRUE)
}

# close rselenium server----
remDr$close()
# remDr$closeServer()
