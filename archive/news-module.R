# news-module.R
# output: news.today news.last
# schedule at 0700 every day

# Problems:
# antarapos,keadilandaily (closed),kosmo,bh,nst,malaysianaccess (closed),malaysiandigest (Australia's news), https://www.malaymail.com/news/malaysia, 
# malaysiadateline, sinchew (closed), malaysianow
# https://www.thestar.com.my/, to add::https://www.asiaone.com/malaysia, https://www.aljazeera.com/where/malaysia/, https://www.malaysiasun.com/,
# https://www.straitstimes.com/tags/malaysia, https://www.malaysia-today.net/category/news/malaysia/
# new:https://defencesecurityasia.com/category/berita/malaysia/

# Steps:
#  1.  news-module.R
#  2.  newsAnalysis.R -- daily analysis report, export daily kpi
#  3.  newsRptClipbySection.Rmd -- news clip
#  newsRpt.Rmd -- daily stat report

# Load libraries
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("RTextTools", quietly = TRUE)) install.packages("RTextTools")
if (!requireNamespace("mongolite", quietly = TRUE)) install.packages("mongolite")
if (!requireNamespace("tidytext", quietly = TRUE)) install.packages("tidytext")
if (!requireNamespace("tm", quietly = TRUE)) install.packages("tm")
if (!requireNamespace("data.table", quietly = TRUE)) install.packages("data.table")

library(dplyr)
library(RTextTools)
library(mongolite)
library(tidytext)
library(tm)
library(data.table)

options(verbose=FALSE)

# Load configuration
load("~/media/binmy.RData")
load("~/media/news_model.RData")

# Logging function
log_message <- function(message) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  cat(paste0("[", timestamp, "] ", message, "\n"))
}

log_message("Starting news-module.R script")

# Load news.last from db
log_message("Loading news.last from MongoDB")
uri <- Sys.getenv("URI")
db <- mongo(collection="news_last", db="news", url=uri)
news.last <- db$find('{}')

# News sources configuration
log_message("Loading news sources configuration")
news.eng <- c("nst", "thestar", "theedge", "dailyexpress","malaysiainsight", "malaysiachronicle","malaysiakini",
              "malaysiandigest", "sinchew","themalaymailonline", "thesundaily","malaysianow","newsarawaktribune",
              "borneopost", "fmt", "selangortimes","dailyexpress","financetwitter","theAseanPost","theRakyatPost")
news.my <- c("agendadaily","amanahdaily","airtimes","antarapos","astroawani","amanahdaily","beritaharian",
             "bernama", "harakah", "hmetro", "keadilandaily", "kosmo", "malaysiadateline",
             "roketkini", "sinarharian","sarawakvoice", "umnoonline", "utusan")

# Improved merge_data function
merge_data <- function(x) {
  log_message(paste("Processing", x))
  
  if (!exists(x)) {
    log_message(paste("Object", x, "does not exist"))
    return(NULL)
  }
  
  df <- get(x)
  if (nrow(df) == 0) {
    log_message(paste("Object", x, "is empty"))
    return(NULL)
  }
  
  # Category classification
  log_message(paste("Classifying", x))
  n <- nrow(df)
  pred_mat <- create_matrix(df$article, originalMatrix = matrix, removeNumbers=TRUE,
                            stemWords=FALSE, weighting=tm::weightTfIdf)
  pred_cont <- create_container(pred_mat, labels = rep("", n), testSize = 1:n, virgin=FALSE)
  pred_df <- classify_model(pred_cont, model)
  
  df <- df %>%
    mutate(kategori = pred_df$SVM_LABEL)
  
  # Sentiment analysis
  log_message(paste("Calculating sentiment for", x))
  if (any(df$src %in% news.my)) {
    tb <- df %>%
      tidytext::unnest_tokens(word, article) %>%
      inner_join(binmy) %>%
      group_by(headlines) %>%
      count(sentiment) %>%
      tidyr::spread(sentiment, n, fill = 0) %>%
      mutate(sentiment = positive - negative, tag = "")
  } else {
    tb <- df %>%
      tidytext::unnest_tokens(word, article) %>%
      inner_join(tidytext::get_sentiments("bing")) %>%
      group_by(headlines) %>%
      count(sentiment) %>%
      tidyr::spread(sentiment, n, fill = 0) %>%
      mutate(sentiment = positive - negative, tag = "")
  }
  
  df <- df %>%
    dplyr::left_join(tb, by = "headlines")
  
  return(df)
}

# News part I
log_message("Starting news part I processing")
batch <- FALSE
thenews <- c("airtimes",
             "bernama",
             "borneopost",
             "fmt",
             "harakah",
             "kosmo",
             "malaysiakini", 
             "malaysianow",
             "malaysiainsight",
             "newsarawaktribune",
             "roketkini",
             "sarawakvoice", 
             "sinarharian",
             "theAseanPost",
             "themalaymailonline",
             "theRakyatPost",
             "thesundaily",
             "umnoonline",
             "utusan")

list.news <- c("agendadaily.df",
             "airtimes.df",
             "astroawani.df",
             "beritaharian.df",
             "bernama.df",
             "borneopost.df",
             "dailyexpress.df", 
             "fmt.df",
             "harakah.df",
             "hmetro.df",
             "kosmo.df",
             "malaysiakini.df", 
             "malaysiainsight.df",
             "newsarawaktribune.df",
             "nst.df",
             "roketkini.df",
             "sarawakvoice.df", 
             "sinarharian.df",
             "theAseanPost.df",
             "theedge.df",
             "themalaymailonline.df",
             "therakyatpost.df", 
             "thestar.df",
             "thesundaily.df",
             "umnoonline.df",
             "utusan.df")

n <- 0
for (i in thenews) {
  log_message(paste("Processing news source:", i))
  cat(i,fill = TRUE,sep = " ")
  try(source(paste0(i,".R")),
      silent=TRUE)
}

# News part II (rselenium)
log_message("Starting news part II processing with RSelenium")
try(source("news_rs_part.R"),silent = TRUE)

# Media clean up, and news.today
log_message("Processing news list")
news.list <- lapply(list.news, merge_data)
news.today <- data.table::rbindlist(news.list,fill = TRUE) %>% distinct()
news.today <- news.today %>% 
  dplyr::anti_join(news.last)

if(nrow(news.today) > 0){
  
  # Save news.last to db
  log_message("Saving news.last to MongoDB")
  news.today %>% 
    select(src, headlines) %>% 
    db$insert()
  
  # Insert news.today | append news.last
  log_message("Inserting news.today into database")
  try(source("newsadddb_mongo.R"),silent = TRUE)
}

# Housekeeping yearly avg | init news.last
log_message("Checking MongoDB size for housekeeping")
if (nrow(news.last) > 144000) {
  log_message("Cleaning up MongoDB collection")
  db <- mongo(collection="news_last", db="news", url=uri)
  db$remove('{}')
  news.today %>% 
    select(src, headlines) %>% 
    db$insert()
}

log_message("Completed news-module.R script")
