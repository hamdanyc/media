word.idx <- function(src.txt, src.key){
  tag <- c("")
  xtag <- c("")
  for(i in 1:nrow(src.txt)){
    xtag <- str_extract(src.txt[i,], paste(src.key, collapse = '|' )) # %>% na.omit()
      try(
        ifelse (!is.na(xtag),
                tag[i] <- paste("**[Tag:", xtag, "]**", src.txt[i,], collapse = "\\n"),
                tag[i] <- paste("**[Tag:", xtag, "]**", src.txt[i,], collapse = "\\n")
        ))
  }
  return(na.omit(tag))
}

# indx <- paste(countries, collapse="|")
# text.df1 <- text.df[grep(indx, text.df$text),]
# text.df1$text <- str_extract(text.df1$text, indx)
# text.df1
# text.df1$text <- unlist(regmatches(text.df1$text, 
#       gregexpr(indx, text.df1$text)))