library(rvest)

url <- "https://scholar.google.com/scholar?as_ylo=2024&q=fine+tuning+language+models&hl=en&as_sdt=0,5"
page <- read_html(url)
titles <- page %>% html_nodes(".gs_rt") %>% html_text()
urls <- page %>% html_nodes(".gs_rt a") %>% html_attr("href")
pdf_urls <- page %>% html_nodes(".gs_or_ggsm a") %>% html_attr("href")