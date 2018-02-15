library(tidyverse)
setwd("~/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/")


NN_100_topics_test_acc = as.data.frame(read.csv("/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/run_dataFor100_run_1l_128__do_03__batch_24__val_01__epochs_30__activationFunction_sigmoid,tag_acc.csv"))
colnames(NN_100_topics_test_acc) <- c("Wall time", "Step", "Value100")
NN_50_topics_test_acc = as.data.frame(read.csv("/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/run_dataFor50_run_1l_128__do_03__batch_24__val_01__epochs_30__activationFunction_sigmoid,tag_acc.csv"))
colnames(NN_50_topics_test_acc) <- c("Wall time", "Step", "Value50")
NN_10_topics_test_acc = as.data.frame(read.csv("/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/run_dataFor10_run_1l_128__do_03__batch_24__val_01__epochs_30__activationFunction_sigmoid,tag_acc.csv"))
colnames(NN_10_topics_test_acc) <- c("Wall time", "Step", "Value10")

NN_test_accuracy = left_join(NN_100_topics_test_acc, NN_50_topics_test_acc, by="Step") %>% 
  left_join(., NN_10_topics_test_acc, by="Step")
NN_test_accuracy %>% 
  gather(key, value, Value100, Value50, Value10) %>%
  ggplot(aes(x = Step, y = value, colour=key)) + geom_line() 
ggsave("test_acc.pdf", plot = last_plot(), path ="/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/graphs")


NN_100_topics_test_loss = as.data.frame(read.csv("/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/run_dataFor100_run_1l_128__do_03__batch_24__val_01__epochs_30__activationFunction_sigmoid,tag_loss.csv"))
colnames(NN_100_topics_test_loss) <- c("Wall time", "Step", "Value100")
NN_50_topics_test_loss = as.data.frame(read.csv("/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/run_dataFor50_run_1l_128__do_03__batch_24__val_01__epochs_30__activationFunction_sigmoid,tag_loss.csv"))
colnames(NN_50_topics_test_loss) <- c("Wall time", "Step", "Value50")
NN_10_topics_test_loss = as.data.frame(read.csv("/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/run_dataFor10_run_1l_128__do_03__batch_24__val_01__epochs_30__activationFunction_sigmoid,tag_loss.csv"))
colnames(NN_10_topics_test_loss) <- c("Wall time", "Step", "Value10")

NN_test_loss = left_join(NN_100_topics_test_loss, NN_50_topics_test_loss, by="Step") %>% 
  left_join(., NN_10_topics_test_loss, by="Step")
NN_test_loss %>% 
  gather(key, value, Value100, Value50, Value10) %>%
  ggplot(aes(x = Step, y = value, colour=key)) + geom_line() 
ggsave("test_loss.pdf", plot = last_plot(),   path ="/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/graphs")


NN_100_topics_val_acc  = as.data.frame(read.csv("/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/run_dataFor100_run_1l_128__do_03__batch_24__val_01__epochs_30__activationFunction_sigmoid,tag_val_acc.csv"))
colnames(NN_100_topics_val_acc) <- c("Wall time", "Step", "Value100")
NN_50_topics_val_acc  = as.data.frame(read.csv("/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/run_dataFor50_run_1l_128__do_03__batch_24__val_01__epochs_30__activationFunction_sigmoid,tag_val_acc.csv"))
colnames(NN_50_topics_val_acc) <- c("Wall time", "Step", "Value50")
NN_10_topics_val_acc  = as.data.frame(read.csv("/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/run_dataFor10_run_1l_128__do_03__batch_24__val_01__epochs_30__activationFunction_sigmoid,tag_val_acc.csv"))
colnames(NN_10_topics_val_acc) <- c("Wall time", "Step", "Value10")

NN_val_accuracy = left_join(NN_100_topics_val_acc, NN_50_topics_val_acc, by="Step") %>% 
  left_join(., NN_10_topics_val_acc, by="Step")
NN_val_accuracy %>% 
  gather(key, value, Value100, Value50, Value10) %>%
  ggplot(aes(x = Step, y = value, colour=key)) + geom_line() 
ggsave("val_acc.pdf", plot = last_plot(), path ="/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/graphs")


NN_100_topics_val_loss  = as.data.frame(read.csv("/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/run_dataFor100_run_1l_128__do_03__batch_24__val_01__epochs_30__activationFunction_sigmoid,tag_val_loss.csv"))
colnames(NN_100_topics_val_loss) <- c("Wall time", "Step", "Value100")
NN_50_topics_val_loss  = as.data.frame(read.csv("/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/run_dataFor50_run_1l_128__do_03__batch_24__val_01__epochs_30__activationFunction_sigmoid,tag_val_loss.csv"))
colnames(NN_50_topics_val_loss) <- c("Wall time", "Step", "Value50")
NN_10_topics_val_loss  = as.data.frame(read.csv("/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/run_dataFor10_run_1l_128__do_03__batch_24__val_01__epochs_30__activationFunction_sigmoid,tag_val_loss.csv"))
colnames(NN_10_topics_val_loss) <- c("Wall time", "Step", "Value10")

NN_val_loss = left_join(NN_100_topics_val_acc, NN_50_topics_val_acc, by="Step") %>% 
  left_join(., NN_10_topics_val_loss, by="Step")

NN_val_loss %>% 
  gather(key, value, Value100, Value50, Value10) %>%
  ggplot(aes(x = Step, y = value, colour=key)) + geom_line()  
ggsave("val_loss.pdf", plot = last_plot(),  path ="/Users/charlvanschoor/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/runs/graphs")
































