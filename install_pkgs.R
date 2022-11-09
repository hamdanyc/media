# install_pkgs.R
# prep list
# awk '/library/' *.R | sort | uniq -u > pkgs.txt

pkgs <- c("rvest",
          "dplyr",
          "devtools",
          "data.table",
          "tidytext",
          "tidyr",
          "readr",
          "stringr",
          "DBI",
          "lubridate",
          "stringr",
          "ggplot2",
          "wordcloud",
          "RColorBrewer",
          "RTextTools",
          "rmarkdown",
          "DT",
          "RMariaDB",
          "kableExtra",
          "knitr")

install.packages(pkgs)

# wordvector package
devtools::install_github("bmschmidt/wordVectors")

# Note: ubuntu packages required for:
# .. package rvest
# sudo apt install libxml2-dev
# sudo apt install libssl-dev
# sudo apt install libcurl4-openssl-dev
# .. RMariaDB
# sudo apt install libmariadb-dev
# .. kableExtra
# sudo apt install libfontconfig1-dev
# topicsmodel had non-zero exit status



