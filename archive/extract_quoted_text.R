# Extract quoted text from R code string
code_string <- 'thenews <- c("airtimes",
             "bernama",
             "borneopost",
             "fmt",
             "harakah",
             "kosmo",
             "malaysiakini", 
             "malaysianow",
             "malaysiainsight",
             "newsarawaktribune",
             "roketkini",
             "sarawakvoice", 
             "sinarharian",
             "theAseanPost",
             "themalaymailonline",
             "theRakyatPost",
             "thesundaily",
             "umnoonline",
             "utusan")'

# Extract all quoted substrings using base R
quoted_matches <- regmatches(code_string, gregexpr('"[^"]*"', code_string))

# Remove the quotes
news_sources <- gsub('"', '', quoted_matches)

# Print the result
print(news_sources)
