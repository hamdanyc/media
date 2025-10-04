# book.R

library(tidyverse)
library(rvest)

url <- "http://books.toscrape.com/catalogue/page-"
pages <- paste0(url, 1:10, ".html")

map_df(pages, function(i){ 
  page <- read_html(i)
  tibble(title = html_nodes(page, "h3, #title") %>% html_text(),
             price = html_nodes(page, ".price_color") %>% html_text() %>% 
               gsub("£", "", .),
             rating = html_nodes(page, ".star-rating") %>% html_attrs() %>% 
               str_remove("star-rating") %>%
               str_replace_all(c("One" = "1", "Two" = "2", 
                                 "Three" = "3", "Four" = "4", "Five" = "5")) %>%  
               as.numeric())
})
