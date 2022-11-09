# ggReadhtml.R

# Read html ---------------------------------------------------------------

theNews <- read_html(searchKey)

headlines <- theNews %>%
  html_nodes(".kWyHVd .ME7ew") %>%
  html_text()

newslink <- theNews %>%
  html_nodes(".kWyHVd .ME7ew") %>%
  html_attr("href")

no.links = length(newslink)
article <- matrix("",no.links)
icss <- matrix("",no.links)
src <- matrix("",no.links)
datePub <- format(Sys.time(), "%d %b %Y")

# Match news to CSS -------------------------------------------------------

cssMatch <- function() {
  result <- matrix("", no.links)
  css <- matrix("", no.links)
  src <- matrix("", no.links)
  n <- nrow(media)
  for (i in 1:length(newslink)) {
    for (j in 1:n) {
      if (grepl(media[j, 1], newslink[i])) {
        css[i] <- as.character(media[j, 3])
        src[i] <- as.character(media[j, 1])
        if(src[i] == "freemalaysiatoday") src[i] <- "fmt"
        break
      }
    }
  }
  result <- data.frame(src, css)
  return(result)
}

# CSS by media type ----------------------------------------------------------------

icss <- cssMatch()

# Harvest article ---------------------------------------------------------

for (i in 1:no.links) {
  try(
    if (icss$src[i] != "") {
      txt <- read_html(newslink[i]) %>% 
        html_nodes(as.character(icss$css[i])) %>%
        html_text()
      txt <- gsub('\\n', ' ', txt)
      txt <- paste(txt, collapse = ' ')
      article[i] <- txt
    }
  )
}