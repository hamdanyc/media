# newsMapPlot.R

library(ggmap)

my <- get_map("malaysia", zoom = 7, maptype = "roadmap")
ggmap(my)
