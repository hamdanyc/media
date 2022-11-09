# newsdailyRS.R
# origin from newsdailyBat.R

# init -----
library(dplyr)
library(RTextTools)
load("newsdaily.RData")
options(verbose=FALSE)
load("binmy.RData")
load("news_model.RData")
batch <- FALSE

news.eng <- c("nst", "thestar", "theedge", "dailyexpress","malaysiainsight", "malaysiachronicle","malaysiakini",
              "malaysiandigest", "sinchew","themalaymailonline", "thesundaily","malaysianow","newsarawaktribune",
              "borneopost", "fmt", "selangortimes","dailyexpress","financetwitter")
news.my <- c("agendadaily","amanahdaily","airtimes","antarapos","astroawani","amanahdaily","beritaharian",
             "bernama", "harakah", "hmetro", "keadilandaily", "hmetro", "kosmo", "malaysiadateline", 
             "malaysianaccess","roketkini", "sinarharian","sarawakvoice", "umnoonline", "utusan")


# server rselenium ----
remDr <- RSelenium::remoteDriver(remoteServerAddr = "192.168.1.123",
                                 port = 4444L,
                                 browserName = "firefox")

remDr$open()

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

thenews <- c("agendadaily",
             "astroawani",
             "beritaharian",
             "hmetro",
             "nst",
             "thestar")

list.news <- c("agendadaily.df",
               "astroawani.df",
               "beritaharian.df",
               "hmetro.df",
               "nst.df",
               "thestar.df")
n <- 0
for (i in thenews) {
  cat(i,fill = TRUE,sep = " ")
  try(source(paste0(i,".R")),
      silent=TRUE)
}

# clean up ----
news.list <- try(lapply(list.news, e),silent = TRUE)
news.today <- data.table::rbindlist(news.list) %>% distinct()

# append to news.last
news.today <- news.today %>% 
  dplyr::anti_join(news.last)

if(count(news.today) > 0){
  news.last <- news.today %>% 
    select(src, headlines) %>% 
    bind_rows(news.last)
}

# insert mariadb ----
con <- RMariaDB::dbConnect(RMariaDB::MariaDB(), username="abi", password="80907299",
                           dbname="news", host="abi-linode.name.my", port="3306")

# Run query to append table from dataframe
DBI::dbAppendTable(con,"text",news.today)
RMariaDB::dbDisconnect(con)

# insert db mongo ----
# Run query to append table from dataframe
connection_string = 'mongodb://192.168.1.124'
db <- mongolite::mongo(collection="media", db="news", url=connection_string)
db$insert(news.today)

# save data ----
save(file = "newsdaily.RData", news.today, news.last)
# system("cp /home/abi/media/newsdaily.RData /home/abi/data") # cp to /mnt/nfsdir

# close rselenium server----
remDr$close()
remDr$closeServer()
