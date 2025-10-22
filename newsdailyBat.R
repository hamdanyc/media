# newsdailyBat.R
# output: news.today news.last
# schedule at 0700 every day

# Problems:
# antarapos,keadilandaily (closed),kosmo,bh,nst,malaysianaccess (closed),malaysiandigest (Australia's news), https://www.malaymail.com/news/malaysia, 
# malaysiadateline, sinchew (closed), malaysianow
# https://www.thestar.com.my/, to add::https://www.asiaone.com/malaysia, https://www.aljazeera.com/where/malaysia/, https://www.malaysiasun.com/,
# https://www.straitstimes.com/tags/malaysia, https://www.malaysia-today.net/category/news/malaysia/
# new:https://defencesecurityasia.com/category/berita/malaysia/

# Steps:
#  1.  newsdailyBat.R
#  2.  newsAnalysis.R -- daily analysis report, export daily kpi
#  3.  newsRptClipbySection.Rmd -- news clip
#  newsRpt.Rmd -- daily stat report

# init -----
library(dplyr)
library(RTextTools)
library(mongolite)

setwd("~/media")
options(verbose=FALSE)
load("~/media/binmy.RData")
load("~/media/news_model.RData")

# load news.last from db ----
# load("newsdaily.RData") | for news.last
uri <- Sys.getenv("URI")
db <- mongo(collection="news_last", db="news", url=uri)
news.last <- db$find('{}')

news.eng <- c("nst", "thestar", "theedge", "dailyexpress","malaysiainsight", "malaysiachronicle","malaysiakini",
              "malaysiandigest", "sinchew","themalaymailonline", "thesundaily","malaysianow","newsarawaktribune",
              "borneopost", "fmt", "selangortimes","dailyexpress","financetwitter","theAseanPost","theRakyatPost")
news.my <- c("agendadaily","amanahdaily","airtimes","antarapos","astroawani","amanahdaily","beritaharian",
             "bernama", "harakah", "hmetro", "keadilandaily", "kosmo", "malaysiadateline",
             "roketkini", "sinarharian","sarawakvoice", "umnoonline", "utusan")

# merge data frame ----
e <- function(x){
  if (exists (x)) {
    df <- get(x)
    
    # set category 
    # identify tag/category ----
    # predict 
    data <- df
    n <- nrow(df)
    pred_mat <- create_matrix(data$article, originalMatrix = matrix, removeNumbers=TRUE,
                              stemWords=FALSE, weighting=tm::weightTfIdf)
    pred_cont <- create_container(pred_mat,labels = rep("",n), testSize = 1:n, virgin=FALSE)
    pred_df <- classify_model(pred_cont,model)

    df <- mutate(df,kategori = pred_df$SVM_LABEL)
    
    # calc sentiment ----
    positive <- 0
    negative <- 0
    
    ifelse(df$src %in% news.my,
           tb <- df %>%
             tidytext::unnest_tokens(word,article) %>%
             inner_join(binmy) %>%
             group_by(headlines) %>%
             count(sentiment) %>%
             tidyr::spread(sentiment, n, fill = 0) %>%
             mutate(sentiment = positive - negative, tag = "")
           ,
           tb <- df %>%
             tidytext::unnest_tokens(word,article) %>%
             inner_join(tidytext::get_sentiments("bing")) %>%
             group_by(headlines) %>%
             count(sentiment) %>%
             tidyr::spread(sentiment, n, fill = 0) %>%
             mutate(sentiment = positive - negative, tag = "")
    )

    df <- df %>%
      dplyr::left_join(tb,by = "headlines")
  }
}

# news part I ----
# add https://theaseanpost.com/geopolitics, https://www.newsarawaktribune.com.my/category/nation/
# https://www.malaysianow.com/section/news/, http://www.financetwitter.com/, https://www.therakyatpost.com/category/news/
# https://thecoverage.my/category/news/, https://malaysiansmustknowthetruth.blogspot.com/
# theEdge has problem?
batch <- FALSE
thenews <- c("airtimes",
             "bernama",
             "borneopost",
             "dailyexpress",
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
  cat(i,fill = TRUE,sep = " ")
  try(source(paste0(i,".R")),
      silent=TRUE)
}

# news part II (rselenium) ----
try(source("news_rs_part.R"),silent = TRUE)

# Media clean up, and news.today ----
news.list <- lapply(list.news, e)
news.today <- data.table::rbindlist(news.list,fill = TRUE) %>% distinct()
news.today <- news.today %>% 
  dplyr::anti_join(news.last)

if(nrow(news.today) > 0){
  
  # save news.last to db ----
  news.today %>% 
    select(src, headlines) %>% 
    db$insert()
  
  # insert news.today | append news.last ----
  try(source("newsadddb_mongo.R"),silent = TRUE)
}

# housekeeping yearly avg | init news.last ----
if (nrow(news.last) > 144000) {
  db <- mongo(collection="news_last", db="news", url=uri)
  db$remove('{}')
  news.today %>% 
    select(src, headlines) %>% 
    db$insert()
}

# prev: save(file = "newsdaily.RData", news.today, news.last)
# system("cp /home/abi/media/newsdaily.RData /home/abi/data") # cp to /mnt/nfsdir
