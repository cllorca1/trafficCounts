

library(dplyr)
library(data.table)
library(ggplot2)

#baysis read----------------------------------------------------------------

setwd("C:/projects/MATSim/trafficCounts/map/bayernWms")

links = fread("networkBaysis.csv")

ggplot(links, aes(x=LENGTH)) + stat_ecdf() + scale_x_log10()


linksFiltered = links %>% filter(LENGTH > 1000)

#matsim read ----------------------------------------------------------------------------

source("C:/code/trafficCounts/common/readLinkStats.R")

scalingVector = c("1.00")
#iterationsVector = c("10","50","100")
iterationsVector = c("50")

#loop to read all the linkstat tables for all the simulated cases - edit for full network

for (scaling in scalingVector){
  for (iterations in iterationsVector){
    
    data = readLinkStats(scaling, iterations)
    #plots the AADT
    rescalingFactor = 1/as.numeric(scaling)
    
    data2 = data %>% select(LINK, HRS0.24avg)
  }
}

#merge ------------------------------------------------------------------------------------


dataAll = merge.data.frame(data2, linksFiltered, by.x = "LINK", by.y = "ID")

#filters the data by Landkreis
unique(dataAll$GEN)
dataAll = dataAll %>% filter(GEN == "MÃ¼nchen" | GEN == "Erding" | GEN == "Dachau" )

scaling = scalingVector[1]
rescalingFactor = 1/as.numeric(scaling)

ggplot(dataAll, aes(x=HRS0.24avg*2*rescalingFactor, y= PVW)) +
  geom_point(alpha = .2) +
  geom_abline(slope = 1, intercept = 0, color = "red") + 
  geom_abline(slope = 1, intercept = 2000, color = "red") + 
  geom_abline(slope = 1, intercept = -2000, color = "red") + 
  xlim(0,100000) + ylim (0,100000)


ggplot(dataAll, aes(x=HRS0.24avg*2*rescalingFactor, y= PVW)) +
  geom_point(alpha = .2) +
  geom_abline(slope = 1, intercept = 0, color = "red") +
  scale_x_log10() + 
  scale_y_log10()

 
averageValue = mean(dataAll$HRS0.24avg)
dataAll$relMatsim = dataAll$HRS0.24avg / averageValue

averageValue = mean(dataAll$PVW)
dataAll$relBaysis = dataAll$PVW/ averageValue

ggplot(dataAll, aes(x=relMatsim, y= relBaysis)) +
  geom_point(alpha = .2) +
  geom_abline(slope = 1, intercept = 0, color = "red") + 
  xlim(0,10) + ylim (0,10)

ggplot(dataAll, aes(x=relMatsim, y= relBaysis)) +
  geom_point(alpha = .2) +
  geom_abline(slope = 1, intercept = 0, color = "red") +
  scale_x_log10() + 
  scale_y_log10()


