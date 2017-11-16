library(dplyr)
library(data.table)
library(ggplot2)


#read matsim linkstats -----------------------------------------------------------------------

source("C:/code/trafficCounts/common/readLinkStats.R")

scalingVector = c("0.01","0.05","0.10","0.20","0.50","1.00")
#iterationsVector = c("10","50","100")
iterationsVector = c("50")

#loop to read all the linkstat tables for all the simulated cases - edit for full network

for (scaling in scalingVector){
  for (iterations in iterationsVector){
    data = readLinkStats(scaling, iterations)
    rescalingFactor = 1/as.numeric(scaling)
    data = data %>% select(LINK, HRS0.24avg)
    data$HRS0.24avg = data$HRS0.24avg* rescalingFactor
    variableName = paste("data",scaling,sep="")
    assign(x = variableName, value = data)
    print(scaling)
  }
}

#reorganize the data

linkStats = data.frame(id = data0.01$LINK)
linkStats$AADT1 = data0.01$HRS0.24avg
linkStats$AADT5 = data0.05$HRS0.24avg
linkStats$AADT10 = data0.10$HRS0.24avg
linkStats$AADT20 = data0.20$HRS0.24avg
linkStats$AADT50 = data0.50$HRS0.24avg
linkStats$AADT100 = data1.00$HRS0.24avg

#test

ggplot(linkStats, aes(x=AADT100, y=AADT50)) + geom_point() + geom_abline(slope = 1, intercept = 0,  color = "green")

#write ooutput file into the gis folder
linkStats$idText = as.character(linkStats$id)
write.csv(x=linkStats, file = "C:/projects/MATsim/trafficCounts/map/shape/linkStats.csv", row.names = F)


#read the gis processed data base for comparison -----------------------------------------------------------------

setwd("C:/projects/MATSim/trafficCounts/map/shape")

results = fread("baysisComparison.txt")

results = results %>% select (PVW, AADT1, AADT5, AADT10, AADT20, AADT50, AADT100, COUNT, CAPACITY, LENGTH)

sum(results$COUNT)

ggplot(results, aes(x=PVW, y=AADT100/COUNT*2)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0,  color = "green") +
  geom_smooth(method='lm',formula=y~x) + 
  xlab("BAYSIS DT working days, light vehicles (veh/day)") + ylab("MATSIM DT (veh/day)") +
  xlim(0,1e5) + ylim(0,1e5)
 