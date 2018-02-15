library(caret)
library(tidyverse)
library(tictoc)

source("utils.R") #for multiplot

setwd("~/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/")
writeLines(paste0("Running 4_GLM.R"))
tic("Running 4_GLM.R")

set.seed(1234)

#get all finalDF .RData names and store them in an ordered dataframe
finalDFs  = list.files(path = "./output/finalDFs-for-all-topics/", pattern = "*.RData")
finalDFs = as.tibble(list(models=finalDFs)) %>%
  mutate(topics = gsub(".RData","",models)) %>%
  separate(topics, into = c("model", "k"), sep = "_") %>%
  select(models, k) %>%
  mutate(k = as.integer(k), models=as.factor(models))
finalDFs= finalDFs[order(finalDFs$k),]

for (model in finalDFs$models){
  writeLines(paste0("busy with ", model))
  RDataFile = paste0("./output/finalDFs-for-all-topics/", model)
  load(RDataFile)
  
  finalDF = finalDF %>% 
    select(-NEWID) %>%
    mutate(SEX = if_else(SEX >=1 & SEX<1.5, "male", if_else(SEX == 1.5, "couple", "female"))) %>%
    mutate(SEX = as.factor(SEX))
  
  NUM_TOPICS = ncol(finalDF)-6
  
  numGifters = nrow(finalDF %>% filter(GIFT == "1"))
  noGiftDF = finalDF %>% 
      filter(GIFT=="0") %>%
      sample_n(size = numGifters)
  
  evenlyDistDF = rbind(finalDF %>% filter(GIFT == "1"), 
                       noGiftDF)
  
  topicColumns = paste0(rep("topic_"), 1:NUM_TOPICS)
  
  #the crazy string hack
  for(column in topicColumns){
    execString = paste0("fileName = paste0('output/topicDistriubtion/",column,"-out-of-",NUM_TOPICS,".pdf');
      pdf(fileName, height=3); 
      print(evenlyDistDF %>%
      ggplot(aes(",column,", fill=GIFT)) + 
      geom_histogram(bins=100) + ggtitle(fileName)); dev.off()")
    writeLines(execString)
    eval(parse(text=execString))
  }

  #helper function to help scale topics
  addOne = function(a) a+1;
  evenlyDistDF = evenlyDistDF %>%
                  mutate_if(is.double, addOne) %>%
                  mutate_if(is.double, log) %>%
                  mutate_if(is.double, scale) 
  
  intrain = createDataPartition(y=evenlyDistDF$GIFT,p=0.7,list=FALSE)
  
  training = evenlyDistDF[intrain,]
  testing = evenlyDistDF[-intrain,] 
  
  dir.create(paste(getwd(),"/output/data/dataFor",NUM_TOPICS, sep=""))
  
  write.csv(training, file = paste0("output/data/dataFor",NUM_TOPICS,"/training.csv"), row.names=FALSE)
  write.csv(testing, file = paste0("output/data/dataFor",NUM_TOPICS,"/testing.csv"), row.names=FALSE)
  
  tic("glm start")
  logisticModel = glm(GIFT ~., data=training, family="binomial")
  toc()
  
  predictedUtil = predict(logisticModel, testing[,-c(1)])
          
  predictedUtilCat = predictedUtil > 0.5
  predictedUtilCatBinary = predictedUtilCat*1
  confMatrix = confusionMatrix(predictedUtilCatBinary, testing$GIFT)
  
  pdf(paste0("output/confusion-matrices/conf-matrix_NUM_TOPICS", NUM_TOPICS, ".pdf"))
  print(ggplot(data = as.data.frame(confMatrix$table), aes(x=Reference, y=Prediction, fill=Freq)) + 
            geom_tile()+
            geom_text(aes(label=as.character(confMatrix$table)), color='white'))
  dev.off()
  #goodness of fitt
  pr2 = rownames_to_column(as.data.frame(pR2(logisticModel)), "metric")
  names(pr2) = c("metric", "val")
  pR2 = pr2[c(4,5),, drop = F]
  
  #confusion metrics
  tidyCF1 = rownames_to_column(as.data.frame(confMatrix$byClass), "metric")
  names(tidyCF1) = c("metric", "val")
  tidyCF2 = rownames_to_column(as.data.frame(confMatrix$overall), "metric")
  names(tidyCF2) = c("metric", "val")
  
  tidyCF = rbind(tidyCF1, pR2)
  pdf(paste0("output/confusion-metrics/conf-metrics-_NUM_TOPICS", NUM_TOPICS, ".pdf"))
  print(tidyCF %>%
    na.omit() %>%
    mutate(metric = as.factor(metric )) %>%
    ggplot()+
    geom_point(aes(x=metric, y=val, color=metric), show.legend =FALSE) + 
    geom_col(aes(x=metric, y=val, fill=metric), width = I(0.1), show.legend =FALSE) + 
    geom_text(aes(x=metric, y=val*1.3,label=round(val,2)))+
    coord_flip())
  dev.off()
  
  # get significance of each variable
  modelSummary = summary(logisticModel)
  coeffs = as.data.frame(modelSummary$coefficients)
  coeffs = cbind(coeffs, rownames(coeffs))
  names(coeffs) = c("Estimate", "StdError", "zVal", "pValue", "X")
  coeffs$X = factor(coeffs$X, levels = coeffs$X[order(coeffs$pValue)])
  
  mostSignificant = coeffs 
  
  #reorder dataframe
  mostSignificant$X = factor(mostSignificant$X, levels = mostSignificant$X[order(mostSignificant$pValue)])
  
  estPlot = mostSignificant %>%
    arrange(pValue) %>% head(20) %>%
    ggplot() +
    geom_col(aes(x=X, y=Estimate, fill=X)) + 
    coord_flip() + 
    theme(legend.position  = "none") 
  
  pPlot =  mostSignificant %>%
    arrange(pValue) %>% head(20) %>%
    ggplot() +
    geom_col(aes(x=X, y=log(1/pValue), fill=X)) + 
    coord_flip() + 
    theme(legend.position = "none") 
  
  pdf(paste0("output/GLM-significantPlots/sigPvalue_NUM_TOPICS", NUM_TOPICS, ".pdf"))
  print(multiplot(estPlot, pPlot, cols=2))
  dev.off()
}

writeLines("Done with GLM.R")
toc()