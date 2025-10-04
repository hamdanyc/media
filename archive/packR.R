# packR.R

library(pak)
library(dplyr)

# read from file
p <- read.csv("pkgs.txt") %>% unlist()

# show dependencies
pkg_deps_tree(p)
pkg_status(p)
pkg_install(p)
