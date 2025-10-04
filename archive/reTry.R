# reTry.R

daily.run <- FALSE
run.lst <- c("newsdailyBat.R", "newsDailyKPIver2.R", "newsRdr.R")

try(
  for (i in run.lst) {
    source(i)
  })