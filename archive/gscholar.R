library(rvest)

# Function to scrape titles, URLs, and PDF file URLs from a Google Scholar page
scrape_google_scholar_page <- function(url) {
  page <- read_html(url)
  
  titles <- page %>% html_nodes(".gs_rt") %>% html_text()
  urls <- page %>% html_nodes(".gs_rt a") %>% html_attr("href")
  # pdf_urls <- page %>% html_nodes(".gs_or_ggsm a") %>% html_attr("href")
  
  results <- data.frame(title = titles, url = urls)
  
  return(results)
}

# Initial URL of the Google Scholar page
base_url <- "https://scholar.google.com/scholar?as_ylo=2024&q=fine+tuning+language+models&hl=en&as_sdt=0,5"
current_results <- scrape_google_scholar_page(base_url)
results <- data.frame()

# Scrape first 3 pages
for (i in 1:5) {
  Sys.sleep(0.7)
  url <- paste0("https://scholar.google.com/scholar?start=", i*10,"&q=fine+tuning+language+models&hl=en&as_sdt=0,5&as_ylo=2024")
  current_results <- scrape_google_scholar_page(url)
  results <- rbind(results, current_results)
  current_page <- current_page + 10
}

# Print the results
write.csv("gscholar.csv",results)