# cleanText.R

cat.key$article <- trimws(cat.key$article)
cat.key$article <- stringr::str_replace_all(cat.key$article, pattern = "[^[:print:]]", " ")
cat.key$article <- stringr::str_replace_all(cat.key$article,
                       pattern = "googletag.cmd.push|\\(function\\(\\) |
                       \\{ googletag.display|
                       \\(‘mm-story-320x100’\\)|
                       \\(‘div-gpt-ad-1471855201557-0’\\)", "")
cat.key$article <- stringr::str_replace_all(cat.key$article,
                       pattern = "googletag.cmd.push\\(function\\(\\) \\{ googletag.display\\(‘mm-story-320x100’\\)\\; \\}\\)", "")
cat.key$article <- stringr::str_replace_all(cat.key$article,
                       pattern = "<U|\\+2015>","")
