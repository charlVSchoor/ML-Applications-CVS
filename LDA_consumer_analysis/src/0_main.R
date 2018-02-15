#this is the main R script, executing this script will execute all of the other scripts, R and python. 
#If this script fails, execute each script individually 

#things to do before executing script:
#install following packages to execute all of the R scripts
#install.packages("tictoc")
#install.packages("tidyverse")
#install.packages("tidytext")
#install.packages("topicmodels")
#install.packages("Rmisc")
#install.packages("plotly")
#install.packages("tm")
#install.packages("stringr")
#install.packages("caret")
#install.packages("Keras)


#set wroking diercotries in each R script - top of documentes

rm(list=ls())

setwd("~/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/")


#clean folders, pictures and RData files
foldersToClean = c("output/CES-distributions/","output/CPP-distribution/","output/GLM-significantPlots/",
                   "output/finalDFs-for-all-topics/","output/product-distribution-per-topic/",
                   "output/product-topic-distribution-RData/","output/top-words-per-topic/",
                   "output/topic-distributions-per-product/","output/topicDistriubtion/",
                   "output/word-count-per-product/", "output/confusion-matrices/", 
                   "output/confusion-metrics/", "output/data/", "runs/")

parent.dir = getwd()

dir.create(paste(parent.dir,"output", sep="/")) 

for (i in 1:length(foldersToClean))  { 
  dir.create(paste(parent.dir,foldersToClean[i], sep="/")) 
}

for(folder in foldersToClean){
  files = list.files(path = folder)
  for(file in files){
    filePath = paste0(folder, file)
    file.remove(filePath)
    writeLines(paste0("Removed ",filePath))
  }
}

source("./1_saveProductTopicDistrubtions.R")
source("./2_prepConsumerExpenditureSurveyData.R")
source("./3_merging_CES_CPP_LDA.R")
source("./4_GLM.R")
#system('python ./5_NN.py')
source("./6_NN_Graphs.R")