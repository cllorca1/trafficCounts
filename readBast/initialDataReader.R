
library(dplyr)

#read the annual data----------------------------------------------------------------------------------------------

setwd("C:/projects/MATSim/trafficCounts/bastAnnual")

#add a new class for numbers with points for thousands
setClass("num.with.commas")
setAs("character", "num.with.commas", 
      function(from) as.numeric(gsub(".", "", from, fixed = T) ) )

#read the data dictionary
dictionary = read.csv("dictionary.csv")
classes = as.list(as.character(dictionary$class))

#read the data
byYearAADT = read.csv2("Zeitreihe.csv", sep = ";", dec = ",", colClasses = classes)

#re-wrtie the data in US format
write.csv(byYearAADT, "ZeitreiheRecoded.csv", row.names = F)

#read already stored data----------------------------------------------------------------------------------------
byYearAADT = read.csv(byYearAADT, "ZeitreiheRecoded.csv")

#obtain a list of stations
stations = unique(byYearAADT$DZ_Nr)

#generate a simple coordinate file-------------------------------------------------------------------------------
simpleFile = byYearAADT %>% filter (Jahr == 2011) %>% select (station = DZ_Nr, lat = Koor_WGS84_N, long = Koor_WGS84_E, direction1 = Fernziel_Ri1, direction2 = Fernziel_Ri2)
setwd("C:/projects/MATSim/trafficCounts/map")
write.csv(simpleFile, "stations2011.csv")


#analyze the annual data ----------------------------------------------------------------------------------------
selectedVariables = subset(dictionary, description != "Not used")$number
summaryByYear = byYearAADT %>% select (selectedVariables)


growthFactors = summaryByYear %>% 
  filter(Jahr == 2011 | Jahr == 2016) %>%
  select(DZ_Nr, Jahr, DTV_Kfz_MobisSo_Q) %>% 
  group_by(Jahr, DZ_Nr) %>% 
  tidyr::spread(Jahr, DTV_Kfz_MobisSo_Q)

growthFactors$growth = growthFactors$`2011` / growthFactors$`2016`
growthFactors$growth[is.na(growthFactors$growth)] = 1

percentHV = byYearAADT %>% group_by(DZ_Nr) %>% summarize(HV = mean(pSV_MobisSo_Q))
percentHV[is.na(percentHV)] = mean(percentHV$HV, na.rm = T)                           



#look for hourly data directory----------------------------------------------------------------------------------
setwd("C:/projects/MATSim/trafficCounts/bastHourly")

dictionaryHourly = read.csv("dictionaryHourlyData.csv")
classesHourly = as.list(as.character(dictionaryHourly$class))

#read hourly data and store it into a large unique database
byHour = data.frame()
for (station in stations){
  fileName = paste("zst",station,".csv",sep="")
  stationData = data.frame()
  stationData =try( read.csv2(fileName, sep = ";", dec = ",", colClasses = classesHourly))
  byHour = rbind(byHour, stationData)

}

#store data
write.csv(byHour, "hourlyData.csv", row.names = F)

#read the already stored data------------------------------------------------------------------------------------
byHour = read.csv("hourlyData.csv")

#filter to weekdays Tu to Th
byHour = byHour %>%
  filter(Wotag == " 2" | Wotag == " 3" | Wotag == " 4") %>% 
  select(Zst, Strklas, Strnum, Datum, Wotag, Stunde, KFZ_R1, KFZ_R2, PLZ_R1, PLZ_R2)

summaryStations = byHour %>% group_by(Zst, Stunde) %>% summarize(count1 = mean(as.numeric(KFZ_R1), na.rm = T),
                                                           count2 = mean(as.numeric(KFZ_R2), na.rm = T), 
                                                           count1L = mean(as.numeric(PLZ_R1), na.rm = T),
                                                           count2L = mean(as.numeric(PLZ_R2), na.rm = T))

#read the list of stations located in the study area
setwd("C:/projects/MATSim/trafficCounts/map")
studyAreaStations = read.csv("stationsStudyArea.csv")


#get a subsample for the study area-------------------------------------------------------------------------------
studyAreaCounts = summaryStations %>% filter(Zst %in% studyAreaStations$station)

#assign values for the study area and print out the xml file------------------------------------------------------



#header:
setwd("C:/projects/MATSim/trafficCounts/toMatsim")
text = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
write(x=text, file="counts.xml", append = F, sep = "")
text = "<counts xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"http://matsim.org/files/dtd/counts_v1.xsd\""
write(x=text, file="counts.xml", append = T, sep = "")
text = "name=\"equilCounts\" desc=\"stations in the Munich study area\"" 
write(x=text, file="counts.xml", append = T, sep = "")
text = "year=\"2011\" layer=\"0\">"
write(x=text, file="counts.xml", append = T, sep = "")

#body:
for (studyAreaStation in studyAreaStations$station){
  links = studyAreaStations %>% filter (station == studyAreaStation)
  counts24 = studyAreaCounts %>% filter(Zst == as.character(studyAreaStation))
  counts24 = counts24 %>% arrange(as.numeric(Stunde))
  #growth factor to convert from 2016 to 2014 (1 if not available, may lead to wrong result if hourly data is 2014 or 2015)
  growthFactor = (growthFactors %>% filter(DZ_Nr == studyAreaStation))$growth[1]
  HV = (percentHV %>% filter(DZ_Nr == studyAreaStation))$HV[1]
  
  #direction 1:
  name = paste(links$station,1,sep="_")
  link = links$Link1
  text = paste("<count loc_id=\"", link, "\" cs_id=\"", name, "\">", sep ="")
  write(x=text, file="counts.xml", append = T, sep = "")
  
  for (hour in 1:24){
    count = counts24$count1[hour] * growthFactor * (100- HV)/100
    if (is.na(count)) {
      count = 0
      print(paste(studyAreaStation, "is not available", sep=" "))
      }
    text = paste("<volume h=\"",hour, "\" val=\"" ,count, "\"/>", sep = "")
    write(x=text, file="counts.xml", append = T, sep = "")
  }
  text = "</count>"
  write(x=text, file="counts.xml", append = T, sep = "")
  
  
  #direction 2:
  name = paste(links$station,2,sep="_")
  link = links$Link2
  text = paste("<count loc_id=\"", link, "\" cs_id=\"", name, "\">", sep ="")
  write(x=text, file="counts.xml", append = T, sep = "")
  
  for (hour in 1:24){
    count = counts24$count2[hour] * growthFactor
    if (is.na(count)) {count = 0}
    text = paste("<volume h=\"",hour, "\" val=\"" ,count, "\"/>", sep = "")
    write(x=text, file="counts.xml", append = T, sep = "")
  }
  text = "</count>"
  write(x=text, file="counts.xml", append = T, sep = "")
 
}

text = "</counts>"
write(x=text, file="counts.xml", append = T, sep = "")

