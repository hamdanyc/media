# astroawani.R

# init -----
library(dplyr)

# get news info ----
# get url 
url <- "https://www.astroawani.com/berita-malaysia"
remDr$navigate(url = url) # Entering our URL

# click more element
Sys.sleep(3)
clickElem <- remDr$findElement(using = "css", "[class = 'css-1eivwdj']")
Sys.sleep(2)
clickElem$clickElement()

headlines <- xml2::read_html(remDr$getPageSource()[[1]]) %>%
  rvest::html_elements(".css-1shzhes h2.css-1wdn56l") %>%
  rvest::html_text()
Sys.sleep(2)
newslink <- xml2::read_html(remDr$getPageSource()[[1]]) %>%
  rvest::html_elements(".css-1shzhes a.css-xm5gxs") %>%
  rvest::html_attr("href")
Sys.sleep(2)
article <- xml2::read_html(remDr$getPageSource()[[1]]) %>%
  rvest::html_elements("div.css-1b4bwu4") %>% 
  rvest::html_text2()

# set page attrib ----
n <- length(headlines)
datePub <- format(Sys.Date(),"%Y/%m/%d")
src <- replicate(n,"astroawani")
datePub <- replicate(n,datePub)
error <- FALSE

# get text && create df ----
# for(i in 1:n){
#   tryCatch(txt <- xml2::read_html(paste0(adurl,newslink[i])) %>%
#              # remDr$findElement(using = "css", "[class = 'article-text new-line']") %>%
#              html_elements("div.css-1b4bwu4") %>% 
#              html_text2(trim = TRUE), error = function(e) e)
#   if(error) break
#   txt <- gsub('\\n', ' ', txt)
#   txt <- paste(txt, collapse = ' ')
#   article[i] <- txt
#   Sys.sleep(1)
# }

# create data frame
astroawani.df <- tibble(src, datePub, headlines, newslink, article)

# calc sentiment & insert db ----
df <- astroawani.df
# if(batch) source("call_sentmnt.R")

