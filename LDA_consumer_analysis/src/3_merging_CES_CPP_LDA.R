library(tidyverse)
library(stringr)

setwd("~/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/")
writeLines(paste0("Running 3_merging_CES_CPP_LDA.R"))
tic("Running 3_merging_CES_CPP_LDA.R")

load("./data/CES.RData")
load("./data/CPP.RData")

LDAmodels  = list.files(path = "./output/product-topic-distribution-RData/", pattern = "*.RData")
LDAmodels = as.tibble(list(models=LDAmodels)) %>%
    mutate(topics = gsub(".RData","",models)) %>%
    separate(topics, into = c("prod", "topic", "dist", "k"), sep = "_") %>%
    select(models, k) %>%
    mutate(k = as.integer(k), models=as.factor(models))

for(model in LDAmodels$models){

  #RDataFile = "./product-topic-distribution-RData/prod_topic_dist_3.RData"
  RDataFile = paste0("output/product-topic-distribution-RData/", model)
  writeLines(RDataFile)
  
  load(RDataFile)
  writeLines(paste0("loaded ", RDataFile, " which took ", round(runtime$toc - runtime$tic,0), " seconds to train"))
  
  names(product_topic_distribution); names(CES); names(CPP)
  str(product_topic_distribution); str(CES); str(CPP)

  #c("topic_1","topic_2","topic_3",...)
  topicColumns = paste0(rep("topic_"), 1:NUM_TOPICS)
  
  topicProductDF = CPP %>% 
    left_join(product_topic_distribution)
  
  #the crazy string hack
  execString = "topicDF = topicProductDF  %>% "
  for(column in topicColumns){
    execString =  str_c(execString, "mutate(",column," = n*",column, ") %>% ")
  }
  execString =  str_c(execString, " group_by(NEWID) %>%  summarise(")
  
  for(column in topicColumns){
    if(column != topicColumns[length(topicColumns)]){
      execString =  str_c(execString, column, " = sum(", column, "),")
    }
    else{
      execString =  str_c(execString, column, " = sum(", column, ")) %>%")
    }
  }
  execString =  str_c(execString, "  mutate(SoS = sqrt(")
  for(column in topicColumns){
    if(column != topicColumns[length(topicColumns)]){
      execString =  str_c(execString, column, "^2+")
    }
    else{
      execString =  str_c(execString, column, "^2)) %>% ")
    }
  }
  execString =  str_c(execString, "mutate(")
  for(column in topicColumns){
    if(column != topicColumns[length(topicColumns)]){
      execString =  str_c(execString, column, " = ", column,"/SoS, ")
    }
    else{
      execString =  str_c(execString, column, " = ", column,"/SoS)")
    }
  }
  
  print(execString)
  eval(parse(text=execString))
  
  topicDF = topicDF %>%
      select(-SoS) %>%
      mutate(NEWID = as.character(NEWID))
  
  finalDF = CES %>% 
      left_join(topicDF)
  
  save(finalDF, file=paste0("output/finalDFs-for-all-topics/finalDFs_", NUM_TOPICS, ".RData"))

}

toc()