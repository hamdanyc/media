# pkg_install.R

library(pak)
library(dplyr)

# read from file
p <- read.csv("pkgs_news.txt") %>% unlist()

# show dependencies
tr <- pkg_deps_tree(p)
st <- pkg_status(p)
pkg_install(p)
