# news_prep_dat.R
# use with newsadddb.R

# Init ----
library(stringr)
library(data.table)
library(readr)
library(dplyr)
library(tidyr)

# Get a List of all files in directory named with a key word, say all `.csv` files
mypath <- paste0(getwd(),"/2018")
filenames <- list.files(path=mypath, pattern="*.csv", full.names=TRUE)

# Read files ----
data <- lapply(filenames, function(x) read_delim(x,","))
df_lst <- data.table::rbindlist(data, fill = TRUE)

# Cleanup Func ----

clean.text <- function(x, lowercase=FALSE, numbers=FALSE, punctuation=FALSE, spaces=TRUE, print=TRUE)
{
  # x: character string
  
  # lower case
  if (lowercase)
    x = tolower(x)
  # remove numbers
  if (numbers)
    x = gsub("[[:digit:]]", "", x)
  # remove punctuation symbols
  if (punctuation){
    x = gsub("[[:punct:]]", "", x)
  }
  if (print){
    x = gsub("[^[:print:]]", " ",x)
  }
  # remove extra white spaces
  if (spaces) {
    x = gsub("[ \t]{2,}", " ", x)
    x = gsub("^\\s+|\\s+$", "", x)
    x = gsub("<.\\+[0-9]+..>", "", x)
    x = gsub("<.\\+[A-Z]*>", "", x)
  }
  # x = gsub("[^\\s.+\>]", "", x)
  # x = gsub("\\\.+", "", x)
  # x = gsub("\\w+.\\w+('').\\s)\\s","", x)
  # x = gsub(".+\\w+\.\\w+\(''\).\\s\).\\s","", x)
  # return
  x
}

# clean-up df ----
df_news <- df_lst %>%
  select(src,datePub,headlines,newslink,article) %>% 
  mutate("headlines"=clean.text(headlines),"newslink"=clean.text(newslink),
         "article"=clean.text(article)) %>% 
  filter(!is.na(article)) %>% 
  filter(!is.na(headlines))

# Calc sentiment ----
# news_calc_sentmnt.R

# Classify ----

# Save ----
save.image(file = "news_raw.RData")

