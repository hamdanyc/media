# newsdailyBat.R
# origin from newsdaily2.R
# schedule at 0700 every day

# Problems:
# antarapos,keadilandaily (closed),kosmo,bh,nst,malaysianaccess (closed),malaysiandigest (Australia's news), https://www.malaymail.com/news/malaysia, 
# malaysiadateline, sinchew, malaysianow
# https://www.thestar.com.my/, to add::https://www.asiaone.com/malaysia, https://www.aljazeera.com/where/malaysia/, https://www.malaysiasun.com/,
# https://www.straitstimes.com/tags/malaysia, https://www.malaysia-today.net/category/news/malaysia/

# Steps:
#  1.  newsdailyBat.R
#  2.  newsAnalysis.R -- daily analysis report, export daily kpi
#  3.  newsRptClipbySection.Rmd -- news clip
#  newsRpt.Rmd -- daily stat report

# init -----
library(dplyr)
load("media.RData")
load("newsdaily.RData")
options(verbose=FALSE)

# Recall yesterday's news ----
# logTime <- format(Sys.time(), "%H:%M:%S")
# set to integer

# Get today's news --------------------------------------------------------
# add https://theaseanpost.com/geopolitics, https://www.newsarawaktribune.com.my/category/nation/
# https://www.malaysianow.com/section/news/, http://www.financetwitter.com/, https://www.therakyatpost.com/category/news/
# https://thecoverage.my/category/news/, https://malaysiansmustknowthetruth.blogspot.com/
batch <- FALSE
thenews <- c("agendadaily",
             "airtimes",
             # "astroawani",
             # "beritaharian",
             # "bernama",
             "borneopost",
             "dailyexpress",
             "fmt",
             "FinanceTwitter",
             "harakah",
             "hmetro",
             "keadilandaily",
             "kosmo",
             "malaysiadateline",
             "malaysiachronicle",
             "malaysiakini",
             "malaysianow",
             "malaysiainsight",
             "newsarawaktribune",
             "nst",
             "roketkini",
             "sarawakvoice",
             "sinarharian",
             "sinchew",
             "theAseanPost",
             "theedge",
             "themalaymailonline",
             "theRakyatPost",
             "theStar",
             "thesundaily",
             "umnoonline",
             "utusan")
n <- 0
for (i in thenews) {
  cat(i,fill = TRUE,sep = " ")
  try(source(paste0(i,".R")),
      silent=TRUE)
}

# Create df ----

news.tmp <- data.frame(src="", datePub="", headlines="", newslink="", article="",
                       stringsAsFactors = FALSE)
for(i in thenews) {
  
  if (exists("agendadaily.df"))
    news.tmp <- news.tmp %>%
      rbind(agendadaily.df)
  if (exists("amanahdaily.df"))
    news.tmp <- news.tmp %>%
      rbind(amanahdaily.df)
  if (exists("airtimes.df"))
    news.tmp <- news.tmp %>%
      rbind(airtimes.df)
  if (exists("antarapos.df"))
    news.tmp <- news.tmp %>%
      rbind(antarapos.df)
  if (exists("astroawani.df"))
    news.tmp <- news.tmp %>%
      rbind(astroawani.df)
  if (exists("beritaharian.df"))
    news.tmp <- news.tmp %>%
      rbind(beritaharian.df)
  if (exists("bernama.df"))
    news.tmp <- news.tmp %>%
      rbind(bernama.df)
  if (exists("borneopost.df"))
    news.tmp <- news.tmp %>%
      rbind(borneopost.df)
  if (exists("dailyexpress.df"))
    news.tmp <- news.tmp %>%
      rbind(dailyexpress.df)
  if (exists("fmt.df"))
    news.tmp <- news.tmp %>%
      rbind(fmt.df)
  if (exists("financetwitter.df"))
    news.tmp <- news.tmp %>%
      rbind(financetwitter.df)
  if (exists("harakah.df"))
    news.tmp <- news.tmp %>%
      rbind(harakah.df)
  if (exists("hmetro.df"))
    news.tmp <- news.tmp %>%
      rbind(hmetro.df)
  if (exists("keadilandaily.df"))
    news.tmp <- news.tmp %>%
      rbind(keadilandaily.df)
  if (exists("kosmo.df"))
    news.tmp <- news.tmp %>%
      rbind(kosmo.df)
  if (exists("malaysianaccess.df"))
    news.tmp <- news.tmp %>%
      rbind(malaysianaccess.df)
  if (exists("malaysiachronicle.df"))
    news.tmp <- news.tmp %>%
      rbind(malaysiachronicle.df)
  if (exists("malaysiadateline.df"))
    news.tmp <- news.tmp %>%
      rbind(malaysiadateline.df)
  if (exists("malaysiainsight.df"))
    news.tmp <- news.tmp %>%
      rbind(malaysiainsight.df)
  if (exists("malaysiakini.df"))
    news.tmp <- news.tmp %>%
      rbind(malaysiakini.df)
  if (exists("malaysianow.df"))
    news.tmp <- news.tmp %>%
      rbind(malaysianow.df)
  if (exists("newsarawaktribune.df"))
    news.tmp <- news.tmp %>%
      rbind(newsarawaktribune.df)
  if (exists("nst.df"))
    news.tmp <- news.tmp %>%
      rbind(nst.df)
  if (exists("roketkini.df"))
    news.tmp <- news.tmp %>%
      rbind(roketkini.df)
  if (exists("sarawakvoice.df"))
    news.tmp <- news.tmp %>%
      rbind(sarawakvoice.df)
  if (exists("sinarharian.df"))
    news.tmp <- news.tmp %>%
      rbind(sinarharian.df)
  if (exists("sinchew.df"))
    news.tmp <- news.tmp %>%
      rbind(sinchew.df)
  if (exists("theedge.df"))
    news.tmp <- news.tmp %>%
      rbind(theedge.df)
  if (exists("malaysiakini.df"))
    news.tmp <- news.tmp %>%
      rbind(malaysiakini.df)
  if (exists("theaseanpost.df"))
    news.tmp <- news.tmp %>%
      rbind(theaseanpost.df)
  if (exists("themalaymailonline.df"))
    news.tmp <- news.tmp %>%
      rbind(themalaymailonline.df)
  if (exists("therakyatpost.df"))
    news.tmp <- news.tmp %>%
      rbind(therakyatpost.df)
  if (exists("thesundaily.df"))
    news.tmp <- news.tmp %>%
      rbind(thesundaily.df)
  if (exists("umnoonline.df"))
    news.tmp <- news.tmp %>%
      rbind(umnoonline.df)
  if (exists("utusan.df"))
    news.tmp <- news.tmp %>%
      rbind(utusan.df)
  if (exists("newstwit.df"))
    news.tmp <- news.tmp %>%
      rbind(newstwit.df)
}

# Media Clean up ----
news.today <- news.tmp
news.today <- news.today %>%
  filter(headlines != "")
news.today <- unique(news.today)

datePub <- format(Sys.Date(), "%Y/%m/%d")
dt <- format(Sys.Date(), "%Y_%m_%d")
news.today$datePub <- datePub

news.today$article <- as.character(news.today$article)

news.today$article <- iconv(news.today$article, to="UTF-8")
news.today$headlines <- iconv(news.today$headlines, to="UTF-8")

news.today$article <- stringr::str_replace_all(news.today$article, 
                                pattern = "[^[:print:]]", " ")
news.today$article <- stringr::str_replace_all(news.today$article,
                                pattern = "googletag.cmd.push|function", "")
news.today$article <- stringr::str_replace_all(news.today$article,
                                pattern = "googletag.display", "")
news.today$article <- stringr::str_replace_all(news.today$article,
                                pattern = "mm-story-320x100", "")
news.today$article <- stringr::str_replace_all(news.today$article,
                                pattern = "div-gpt-ad-1471855201557-0", "")
news.today$article <- stringr::str_replace_all(news.today$article,
                                              pattern = "[();]","")
news.today <- news.today %>%
  anti_join(news.last, by= c("headlines","src"))

if(count(news.today) > 0){
  news.last <- news.today %>% 
    select(src, headlines) %>% 
    rbind(news.last)
}

# assign categories to each article
# DISABLE
# textDf <- tidytext::unnest_tokens(news.today, word, article)
# prob.cat <- textDf %>%   
#   inner_join(cat.term) %>%
#   select(headlines, Kategori) %>%
#   group_by(headlines) %>%
#   summarise(Kategori_1=first(Kategori),Kategori_2=last(Kategori))

save(file = "newsdaily.RData", news.today, news.last)
# system("cp /home/abi/media/newsdaily.RData /home/abi/data") # cp to /mnt/nfsdir
