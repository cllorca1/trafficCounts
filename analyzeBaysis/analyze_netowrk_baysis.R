

library(dplyr)
library(data.table)
library(ggplot2)

setwd("C:/projects/MATSim/trafficCounts/map/bayernWms")

links = fread("networkBaysis.csv")

ggplot(links, aes(x=DistToCoun)) + stat_ecdf() + scale_x_log10()


linksWithCount = links %>% filter(DistToCoun < 10)

linksWithCount = links %>% filter(DistToCoun < 20)

linksWithCount = links %>% filter(DistToCoun < 30)
