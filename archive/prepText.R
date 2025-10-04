# prepText.R
# use with modelAnalysis.R

# Init --------------------------------------------------------------------
library(stringr)
library(data.table)
library(readr)
library(wordVectors)
library(dplyr)
library(tidyr)

# Get a List of all files in directory named with a key word, say all `.csv` files
mypath <- paste0(getwd(),"/arkib")
filenames <- list.files(path=mypath, pattern="*.zip", full.names=TRUE)
# filenames <- "C:/Users/abi/OneDrive/Project R/media/arkib/2018_02_26news.csv"

# file.set <- tail(filenames,25)

# Read files --------------------------------------------------------------

# read and row bind all data sets
# data <- rbindlist(lapply(filenames,
#                          fread( blank.lines.skip=TRUE,verbose=TRUE,
#                                 select = 1)))

# data <- read_delim(filenames[1],"|")
data <- lapply(filenames[4:25], function(x) read_delim(x,"|"))
# artikel <- data[[1]][["article"]]

# data <- rbindlist(lapply(filenames,function(x) read_csv(x,col_types = cols(datePub = col_skip(), 
#                                                   headlines = col_skip(), newslink = col_skip(),
#                                                   src = col_skip()))))
# convert list to data frame
# dflst <- Map(as.data.frame, data[])
df_lst <- rbindlist(data, fill = TRUE)

# ext articles
dt <- df$article
dt <- na.omit(dt)

df <- lapply(dt, function(x) toString(x))
artikel <- unlist(df)

# Cleanup -----------------------------------------------------------------

clean.text <- function(x, lowercase=TRUE, numbers=TRUE, punctuation=TRUE, spaces=TRUE)
{
  # x: character string
  
  # lower case
  if (lowercase)
    x = tolower(x)
  # remove numbers
  if (numbers)
    x = gsub("[[:digit:]]", "", x)
  # remove punctuation symbols
  if (punctuation)
    x = gsub("[[:punct:]]", "", x)
  # remove extra white spaces
  if (spaces) {
    x = gsub("[ \t]{2,}", " ", x)
    x = gsub("^\\s+|\\s+$", "", x)
  }
  # return
  x
}

# txt <- clean_string(artikel)
txt <- clean.text(artikel, numbers = FALSE)
write.table(txt, "artikel.txt",row.names = F)

# Building test data ------------------------------------------------------

# vector space model
source("mediaVector.R")
