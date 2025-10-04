# newsMerge.R

# init ----
library(dplyr)
library(RTextTools)

load("news.RData")

news.eng <- c("nst", "thestar", "theedge", "dailyexpress","malaysiainsight", "malaysiachronicle",
              "malaysiandigest", "sinchew","themalaymailonline", "thesundaily","malaysianow","NewSarawakTribune",
              "borneopost", "fmt", "selangortimes","dailyexpress","theedge")
news.my <- c("agendadaily","amanahdaily","airtimes","TheRakyatPost","astroawani","amanahdaily","beritaharian","sarawakvoice",
             "bernama", "harakahdaily", "keadilandaily", "hmetro", "kosmo", "malaysiadateline","sinarharian", 
             "malaysianaccess","malaysiakini", "roketkini", "sinarharian","sarawakvoice", "umnoonline", "utusan")

# identify tag/category ----
# predict 
# data <- news.today
# n <- nrow(news.today)
# pred_mat <- create_matrix(data$article, originalMatrix = matrix, removeNumbers=TRUE,
#                           stemWords=FALSE, weighting=tm::weightTfIdf)
# pred_cont <- create_container(pred_mat,labels = rep("",n), testSize = 1:n, virgin=FALSE)
# pred_df <- classify_model(pred_cont,model)

df <- mutate(news.today,kategori = "") %>% 
  na.omit() %>% 
  distinct()
df <- df[-1,]

# calc sentiment ----
positive <- 0
negative <- 0

tb <- if_else(df$src %in% news.my, {
  df %>%
    tidytext::unnest_tokens(word,article) %>% 
    inner_join(binmy) %>%
    group_by(headlines) %>%
    count(sentiment) %>%
    tidyr::spread(sentiment, n, fill = 0) %>%
    mutate(sentiment = positive - negative)
},
{
  df %>%
    tidytext::unnest_tokens(word,article) %>% 
    inner_join(tidytext::get_sentiments("bing")) %>%
    group_by(headlines) %>%
    count(sentiment) %>%
    tidyr::spread(sentiment, n, fill = 0) %>%
    mutate(sentiment = positive - negative)
})

x <- list("airtimes.df","borneopost.df")
y <- list(airtimes.df,borneopost.df)
li <- list()
add_li <- function(x,y) ifelse(exists(x),list(y),"")
li <- mapply(add_li, x,y )

li <- if(exists("airtimes.df")) list(airtimes.df)
li <- if(exists("borneopost.df")) list(li,borneopost.df)
li <- if(exists("dailyexpress.df")) list(li,dailyexpress.df)

list(airtimes.df,borneopost.df,dailyexpress.df)

