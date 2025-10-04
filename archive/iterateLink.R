library(rvest)
library(stringr)
library(data.table)
lego_movie <- read_html("http://www.imdb.com/title/tt1490017/")
cast <- lego_movie %>%
  html_nodes("#titleCast .itemprop span") %>%
  html_text()
cast

s <- html_session("http://www.imdb.com/title/tt1490017/")

cast_movies <- list()

for(i in cast[1:3]){
  actorpage <- s %>% follow_link(i) %>% read_html()
  cast_movies[[i]]$movies <-  actorpage %>% 
    html_nodes("b a") %>% html_text() %>% head(10)
  cast_movies[[i]]$years <- actorpage %>%
    html_nodes("#filmography .year_column") %>% html_text() %>% 
    head(10) %>% str_extract("[0-9]{4}")
  cast_movies[[i]]$name <- rep(i, length(cast_movies[[i]]$years))
}

cast_movies
as.data.frame(cast_movies[[1]])
rbindlist(cast_movies)