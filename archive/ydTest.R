library(RYandexTranslate)

ls("package:RYandexTranslate")
api_key="trnsl.1.1.20170921T135051Z.dadab837b9f30ad8.cb155598e25efa157ed0be5188c112611af67efe"
directions=get_translation_direction(api_key)
head(directions)
# ctext = "槟再出发志工今明出动‧洗刷刷还原槟城
ctext <- "This Policy sets out MPay’s overall position on bribery and corruption in all its forms. 
  The Policy is not intended to be exhaustive as there may be additional obligations that 
  the Personnel is expected to adhere to or comply when performing their duties. For all 
  intents and purposes, the Personnel shall always observe and ensure compliance with 
  this Policy and all applicable laws, rules and regulations in the performance of their 
  duties"
data=translate(api_key,text="hello", lang = "en-fr")
data

# translate = function (api_key, text = "", lang = "") 
# {
#   url = "https://translate.yandex.net/api/v1.5/tr.json/translate?"
#   url = paste(url, "key=", api_key, sep = "")
#   if (text != "") {
#     url = paste(url, "&text=", text, sep = "")
#   }
#   if (lang != "") {
#     url = paste(url, "&lang=", lang, sep = "")
#   }
#   url = gsub(pattern = " ", replacement = "%20", x = url)
#   d = RCurl::getURL(url, ssl.verifyhost = 0L, ssl.verifypeer = 0L)
#   d = jsonlite::fromJSON(d)
#   d$code = NULL
#   d
# }
