# news_calc_cat.R

# Init ----
library(RTextTools)
library(dplyr)
load("news_model.RData")
load("news_cat.RData")

# tag by Categories ----
# predict 
# rm(list = c("data","df_lst","df_news","binmy","eng.news","my.news"))
cohort <- function(df){
  n <- nrow(df)
  new_data <- df
  pred_mat <- create_matrix(new_data$article, originalMatrix = matrix, removeNumbers=TRUE,
                            stemWords=FALSE, weighting=tm::weightTfIdf)
  pred_cont <- create_container(pred_mat,labels = rep("",n), testSize = 1:n, virgin=FALSE)
  pred_df <- classify_model(pred_cont,model)
  rf <- mutate(df,kategori = pred_df$SVM_LABEL)
}

# cohort ----
df <- ungroup(df)
dt1 <- cohort(df[1:2000,])
dt2 <- cohort(df[2001:4000,])
dt3 <- cohort(df[4001:6000,])
dt4 <- cohort(df[6001:8000,])
dt5 <- cohort(df[8001:10000,])
dt6 <- cohort(df[10001:12000,])
dt7 <- cohort(df[12001:14000,])
dt8 <- cohort(df[14001:16000,])
dt9 <- cohort(df[16001:18000,])
dt10 <- cohort(df[18001:20000,])
dt11 <- cohort(df[20001:22000,])
dt12 <- cohort(df[22001:24000,])
dt13 <- cohort(df[24001:26000,])
dt14 <- cohort(df[26001:28000,])
dt15 <- cohort(df[28001:30000,])
dt16 <- cohort(df[30001:32000,])
dt17 <- cohort(df[32001:34000,])
dt18 <- cohort(df[34001:36000,])
dt19 <- cohort(df[36001:38000,])
dt20 <- cohort(df[38001:40000,])
dt21 <- cohort(df[40001:42000,])
dt22 <- cohort(df[42001:44000,])
dt23 <- cohort(df[44001:46000,])
dt24 <- cohort(df[46001:48000,])
dt25 <- cohort(df[48001:50000,])
dt26 <- cohort(df[50001:52000,])
dt27 <- cohort(df[52001:54000,])
dt28 <- cohort(df[54001:54524,])

# Save data ----
save.image("news_cat.RData")
