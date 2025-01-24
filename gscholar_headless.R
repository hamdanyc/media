# gscholar_headless.R

library(RSelenium)
library(rvest)

# server rselenium ----
remDr <- RSelenium::remoteDriver(remoteServerAddr = "192.168.1.116",
                                 port = 4444L,
                                 browserName = "firefox")

remDr$open()

# Navigate to Google Scholar
remDr$navigate("https://scholar.google.com/")

# Find and interact with elements on the page
search_box <- remDr$findElement(using = 'css selector', value = '#gs_hdr_tsi')
search_box$sendKeysToElement(list("fine tuning LLM", key = "enter"))

# Verify page source
page <- remDr$getPageSource()

# Example: Get titles of search results
titles <- remDr$findElements(using = 'css selector', value = '.gs_rt')
for (title in titles) {
  print(title$getElementText())
}

# Stop the Selenium server
remDr$close()
driver$server$stop()