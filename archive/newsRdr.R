# newsrdr.R

library(rmarkdown)

# Sys.setenv(RSTUDIO_PANDOC="/usr/share/positron/resources/app/quarto/bin/tools/x86_64")

# render the default (first) format defined in the file
render("newsClipbySection.Rmd", output_format = "html_document", 
       output_file = "sorotan.html")

