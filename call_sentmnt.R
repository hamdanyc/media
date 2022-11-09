# call_sentmnt.R

# init ----
library(dplyr)
library(RTextTools)

load("binmy.RData")
load("news_model.RData")

news.eng <- c("nst", "thestar", "theedge", "dailyexpress","malaysiainsight", "malaysiachronicle","malaysiakini",
              "malaysiandigest", "sinchew","themalaymailonline", "thesundaily","malaysianow","newsarawaktribune",
              "borneopost", "fmt", "selangortimes","dailyexpress","financetwitter")
news.my <- c("agendadaily","amanahdaily","airtimes","antarapos","astroawani","amanahdaily","beritaharian",
             "bernama", "harakah", "hmetro", "keadilandaily", "hmetro", "kosmo", "malaysiadateline", 
             "malaysianaccess","roketkini", "sinarharian","sarawakvoice", "umnoonline", "utusan")

# identify tag/category ----
# predict 
data <- df
n <- nrow(df)
pred_mat <- create_matrix(data$article, originalMatrix = matrix, removeNumbers=TRUE,
                          stemWords=FALSE, weighting=tm::weightTfIdf)
pred_cont <- create_container(pred_mat,labels = rep("",n), testSize = 1:n, virgin=FALSE)
pred_df <- classify_model(pred_cont,model)

df <- mutate(df,kategori = pred_df$SVM_LABEL)


