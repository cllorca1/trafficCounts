
folder = "c:/projects/MATSim/trafficCounts/fromMatsim/compareWithEF/"

fileNo = "ADT_BASt.csv"

dataNo = read.csv(paste(folder,fileNo, sep=""))

fileYes = "ADT_BASt_EF.csv"

dataYes = read.csv(paste(folder,fileYes, sep=""))


dataNo$run = "without"
dataYes$run = "with"

data = rbind(dataNo, dataYes)

library(ggplot2)


ggplot(data, aes(x=Real, y=Simulation, group = as.factor(Link.Id), color = as.factor(run))) +
  geom_point() +
  geom_line(arrow = arrow(length=unit(0.30,"cm"))) + 
  scale_x_log10(limits = c(1000,100000)) + scale_y_log10(limits = c(1000,100000)) +
  geom_abline(intercept = 0, slope = 1)

