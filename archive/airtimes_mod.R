# airtimes_mod.R

# Init ----
library(rvest)
library(dplyr)
library(tibble)
library(progress)
library(httr)

# Function to scrape article content with retry logic
scrape_article <- function(url, max_retries = 3) {
  for (retry in 1:max_retries) {
    tryCatch({
      response <- GET(url,
                      add_headers(`User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"))
      
      if (status_code(response) == 200) {
        page <- read_html(content(response, "text", encoding = "UTF-8"))
        text <- page %>%
          html_nodes("p") %>%
          html_text2() %>%
          paste(collapse = " ") %>%
          gsub(pattern = "\\s+", replacement = " ", x = .)
        
        return(text)
      } else {
        message("HTTP error ", status_code(response), " for ", url)
        if (retry < max_retries) {
          message("Retrying... (", retry, "/", max_retries, ")")
          Sys.sleep(2^retry)  # Exponential backoff
          next
        } else {
          return(NA_character_)
        }
      }
    }, error = function(e) {
      message("Error scraping ", url, ": ", e$message)
      if (retry < max_retries) {
        message("Retrying... (", retry, "/", max_retries, ")")
        Sys.sleep(2^retry)  # Exponential backoff
        next
      } else {
        return(NA_character_)
      }
    })
  }
  return(NA_character_)
}

# Read html ----
theNews <- read_html("http://www.airtimes.my/")

# Extract headlines and links
headlines <- theNews %>%
  html_nodes(".magcat-titlte a") %>%
  html_text() %>%
  unlist() %>%
  as_tibble() %>%
  rename(headlines = value)

newslink <- theNews %>%
  html_nodes(".magcat-titlte a") %>%
  html_attr("href") %>%
  unlist() %>%
  as_tibble() %>%
  rename(newslink = value)

# Validate that we have the same number of headlines and links
if (nrow(headlines) != nrow(newslink)) {
  stop("Mismatch between number of headlines and links")
}

# Create base data frame
no.links <- nrow(headlines)
datePub <- replicate(no.links, format(Sys.Date(), "%Y/%m/%d"))
src <- replicate(no.links, "airtimes")

# Scrape article content with progress bar
article <- character(no.links)
pb <- progress::progress_bar$new(
  total = no.links,
  format = "Scraping articles: :current/:total [:bar] :percent"
)

for (i in seq_along(newslink$newslink)) {
  Sys.sleep(0.7)
  article[i] <- scrape_article(newslink$newslink[i])
  pb$tick()
}

# Create final data frame
airtimes.df <- tibble(
  src = src,
  datePub = datePub,
  headlines = headlines$headlines,
  newslink = newslink$newslink,
  article = article
)

# calc sentiment & insert db ----
df <- airtimes.df
