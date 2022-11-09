# binmySimilar.R

library(wordVectors)
library(tidytext)
library(dplyr)
library(tidyr)
library(readr)

# Read in model ------------------------------------------------------

load("binmy.RData")
model <- read.binary.vectors("media.vector.bin") # created from mediaVector.R

# is_similar <- function(theword,thesent){
#   similar_word <- model %>% improve_vectorspace() %>% 
#     closest_to(theword,5)
#   result <- data.frame(similar_word$word,thesent)
#   return(result)
# }

is_similar <- function(theword){
  similar_word <- model %>% improve_vectorspace() %>% 
    closest_to(theword,2)
  result <- similar_word$word
  return(result)
}

# Find Similar ------------------------------------------------------------

i <- nrow(binmy)
# newword <- data.frame("word"=binmy$word, "sent"=binmy$sentiment)
newword <- data.frame("word"=binmy$word) %>% head(i)
newsent <- data.frame("word"=binmy$sentiment) %>% head(i)

# transpose with t
sim.word <- apply(newword,1,function(x) is_similar(x))

cbind(t(sim.word)[,2],newsent) %>%
  write.table("simword.csv",row.names = F, sep = ",",
            quote = F,col.names = c("word","sentiment"))

# Add Entry ---------------------------------------------------------------

binmy.add <- read_csv("simword.csv")

bmy.new <- binmy.add %>% 
  left_join(binmy) %>%
  filter(!is.na(sentiment))

binmy <- binmy %>% 
  rbind(bmy.new)

binmy <- unique(binmy)
save(binmy,file = "binmy.RData")

# sim.word <- mapply(is_similar,newword,newsent)
# mylist <- list(a=1,b=2,c=3)
# myfxn <- function(var1,var2){
#   var1*var2
# }
# var2 <- 2
# 
# sapply(mylist,myfxn,var2=var2)
# mapply(myfun, arg1, arg2)
