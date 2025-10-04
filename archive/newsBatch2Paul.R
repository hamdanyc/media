# newsBatch2Paul.R
# schedule at 0600, 1400 and 2200 every day

# setwd("C:/Users/hy/OneDrive/Project R/media")
(WD <- getwd())
if (!is.null(WD)) setwd(WD)

run.lst <- c("newsAnalysis.R", "newsMail2Paul.R")

try(
  for (i in run.lst) {
    source(i)
  })
