# packR.R

pack <- c("dplyr", "gmailr", "rmarkdown", "tidytext", "tidyr", "stringr", "ggplot2",
          "knitr", "kableExtra", "topicmodels", "wordcloud", "SnowballC", "twitteR")
if(!require(pack)){
  install.packages(pack)
}
