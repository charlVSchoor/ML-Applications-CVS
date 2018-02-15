library(tictoc)
library(tidyverse)

writeLines(paste0("Running 2_prepConsumerExpenditureSurveyData.R"))
setwd("~/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/")
tic("Running 2_prepConsumerExpenditureSurveyData.R")

fmld_df = rbind(read.csv("./data/diary13/fmld131.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary13/fmld132.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary13/fmld133.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary13/fmld134.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary14/fmld141.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary14/fmld142.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary14/fmld143.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary14/fmld144.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary15/fmld151.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary15/fmld152.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary15/fmld153.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary15/fmld154.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary16/fmld161.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary16/fmld162.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary16/fmld163.csv")%>% select(NEWID, STATE, INCLASS),
                read.csv("./data/diary16/fmld164.csv")%>% select(NEWID, STATE, INCLASS))

memd_df = rbind(read.csv("./data/diary13/memd131.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary13/memd132.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary13/memd133.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary13/memd134.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary14/memd141.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary14/memd142.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary14/memd143.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary14/memd144.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary15/memd151.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary15/memd152.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary15/memd153.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary15/memd154.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary16/memd161.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary16/memd162.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary16/memd163.csv")%>% select(NEWID, AGE, EDUCA, SEX),
                read.csv("./data/diary16/memd164.csv")%>% select(NEWID, AGE, EDUCA, SEX))

expd_df = rbind(read.csv("./data/diary13/expd131.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO),
                read.csv("./data/diary13/expd132.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO),
                read.csv("./data/diary13/expd133.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO),
                read.csv("./data/diary13/expd134.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO),
                read.csv("./data/diary14/expd141.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO),
                read.csv("./data/diary14/expd142.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO),
                read.csv("./data/diary14/expd143.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO),
                read.csv("./data/diary14/expd144.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO),
                read.csv("./data/diary15/expd151.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO), 
                read.csv("./data/diary15/expd152.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO), 
                read.csv("./data/diary15/expd153.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO), 
                read.csv("./data/diary15/expd154.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO),
                read.csv("./data/diary16/expd161.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO),
                read.csv("./data/diary16/expd162.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO),
                read.csv("./data/diary16/expd163.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO),
                read.csv("./data/diary16/expd164.csv")%>% select(NEWID, GIFT, UCC, EXPNYR, EXPNMO))

tidy_expd = expd_df %>%
    filter(GIFT != "C") %>%
    mutate(GIFT = if_else(GIFT == "1", 1, 0)) %>%
    mutate(TIMESTAMP = paste0(EXPNYR, EXPNMO))

household_gifts = tidy_expd %>%
    group_by(NEWID) %>%
    summarise(GIFT = sum(GIFT)) %>%
    mutate(GIFT = if_else(GIFT == 0, 0, 1)) %>%
    mutate(GIFT = as.factor(GIFT)) 

tidy_memd = memd_df %>%
    group_by(NEWID) %>%
    summarise(AGE = mean(AGE,  na.rm=TRUE),
              EDUCA = max(EDUCA,  na.rm=TRUE),
              SEX = mean(SEX,  na.rm=TRUE))

CES = household_gifts %>%
      left_join(tidy_memd) %>%
      left_join(fmld_df) %>%
      mutate(STATE = if_else(is.na(STATE), 0, as.double(STATE))) %>%
      mutate(EDUCA = as.factor(EDUCA),
             STATE = as.factor(STATE),
             NEWID = as.factor(NEWID), 
             INCLASS = as.factor(INCLASS))

#average products per time stamp proxying as consumer product propensity (CPP)
CPP = tidy_expd %>% 
  count(NEWID, UCC, TIMESTAMP) %>%
  ungroup() %>%
  group_by(NEWID, UCC) %>%
  summarise(n = mean(n)) %>%
  ungroup() %>%
  rename(product=UCC) %>%
  mutate(product = as.factor(as.character(product)))


save(CES, file="data/CES.RData")
writeLines(paste0("saved data/CES.RData"))
save(CPP, file="data/CPP.RData")
writeLines(paste0("saved data/CPP.RData"))

pdf("output/CES-distributions/AGE.pdf", height=3)
print(CES %>% ggplot(aes(AGE, fill=GIFT)) + geom_histogram()); dev.off()

pdf("output/CES-distributions/SEX.pdf", height = 3)
print(CES %>% ggplot(aes(SEX, fill=GIFT)) + geom_histogram()); dev.off()

pdf("output/CES-distributions/EDUCA.pdf", width=4)
print(CES %>% count(GIFT, EDUCA) %>% ggplot() + geom_col(aes(x=EDUCA, y=n, fill=GIFT)) + coord_flip()); dev.off()

pdf("output/CES-distributions/STATE.pdf", width=4)
print(CES %>% count(GIFT, STATE) %>% ggplot() + geom_col(aes(x=STATE, y=n, fill=GIFT)) +coord_flip()); dev.off()

pdf("output/CES-distributions/INCLASS.pdf", width=4)
print(CES %>% count(GIFT, INCLASS) %>% ggplot() + geom_col(aes(x=INCLASS, y=n, fill=GIFT)) +coord_flip()); dev.off()

m = as.matrix(CPP %>% spread(product, n))
collist<- c("#5148b2", "#7475b6","#abb5ff","#c9ebff","#e1f8ff")
ColorRamp<-colorRampPalette(collist)(length(collist))

png("output/CPP-distribution/CPP_distribution.png")
par(mar=c(0, 0, 0, 0))
image(t(log(m)), col=ColorRamp, useRaster=TRUE, axes=FALSE)
text(0.07,0.5,"NEWID", col="black", cex=1.5)
text(0.5,0.02,"Product", col="black", cex=1.5)
dev.off()

toc()