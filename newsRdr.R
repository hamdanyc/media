# newsrdr.R

library(rmarkdown)

# render the default (first) format defined in the file
render("newsClipbySection.Rmd", output_format = "html_document", 
       output_file = "sorotan.html")

