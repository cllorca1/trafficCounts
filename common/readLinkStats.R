readLinkStats = function(scaling, iterations){

#set fixed parameters
path = "C:/models/munich/output/1.000.75"
exponentCF = 1
exponentSF = 0.75
#read data

capacity = paste(format(round(as.numeric(scaling)^as.numeric(exponentCF),2),nsmall = 2))
storage = paste(format(round(as.numeric(scaling)^as.numeric(exponentSF),2),nsmall = 2))
simulationName = paste("TF",scaling,"CF",capacity,"SF",storage,"IT",iterations,"scalingSFExp",exponentSF,"CFExp",exponentCF, "TEST", sep = "")
lastIterationPath = paste("it.",iterations, sep="")
fileName = paste("scalingSFExp",exponentSF,"CFExp",exponentCF,"TEST_2016.",iterations,".linkstats.txt.gz",sep = "")
pathToFile = paste(path,simulationName,"ITERS",lastIterationPath,fileName,sep = "/")

data = read.csv(pathToFile, sep = "\t", header=TRUE)


}