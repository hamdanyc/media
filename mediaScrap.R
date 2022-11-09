# mediaScrap.R

# Init --------------------------------------------------------------------

library(rvest)
library(dplyr)

thestar <- read_html("http://www.thestar.com.my/news/nation")
ss <- html_session("http://www.thestar.com.my/news/nation")

headlines <- thestar %>%
  html_nodes(".m a") %>%
  html_text()

newsrc <- thestar %>%
  html_nodes(".m a") %>%
  html_attr("href")

# thestar %>% 
#   html_nodes(".m a") %>%
#   html_attrs()

no.links = length(newsrc)
article <- matrix("",no.links)

for (i in 1:no.links) {

  ifelse (i < 5,
      urlink <- newsrc[i],
      urlink <- paste("http://www.thestar.com.my",
                      newsrc[i], sep = "")
  )
  
  txt <- read_html(urlink) %>% 
    html_nodes("#slcontent3_6_sleft_0_storyDiv p") %>%
    html_text()
  txt <- gsub('\\n', ' ', txt)
  txt <- paste(txt, collapse = ' ')
  article[i] <- txt
}
