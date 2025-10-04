# newsBatch.R

# run.lst <- c("newsdailyBat.R", "newsadddb_mongo.R"", "newsRdr.R", "newsMail.R")
run.lst <- c("newsdailyBat.R", "newsRdr.R")

try(
  for (i in run.lst) {
    source(i)
})
