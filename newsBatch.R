# newsBatch.R

setwd("~/media")
.libPaths(c("~/R/x86_64-pc-linux-gnu-library/3.6","/usr/local/lib/R/site-library"))

# run.lst <- c("newsdailyBat.R", "newsDailyKPIVer2.R", "newsRdr.R", "newsMail.R")
run.lst <- c("newsdailyBat.R","newsadddb_mongo.R", "newsRdr.R")

try(
  for (i in run.lst) {
    source(i)
})

# scp rstudio@192.168.1.121:/home/rstudio/media/newsdaily.RData