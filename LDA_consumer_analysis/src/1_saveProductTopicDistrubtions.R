#R script to reads in wikipediaDefitions.csv defined as product|description
#and saves the LDA topic distributions for NUM_TOPICS topics in product-topic-distribution-RData/prod_topic_dist_NUM_TOPICS.RData
#the script also saves a few graphs in top-words-per-topic/, word-count-per-product/, topic-distributions-per-product/, product-distribution-per-topic/

library(tictoc)
library(tidyverse)
library(tidytext)
library(topicmodels)
library(plotly)
library(tm)

setwd("~/Documents/Gottingen/ML/ML-Applications-CVS/LDA_consumer_analysis/src/")
writeLines(paste0("Running 1_saveProductTopicDistrubtions.R"))
tic("Running 1_saveProductTopicDistrubtions.R")

set.seed(1234)

OWN_STOP_WORDS = c('1', '2', '3', '4', '5', '6', 'consisting', 
                   'designed', 'motion', 'children\'s', 'contact', 
                   'typically', 'musa', 'term', 'items', 'mro', 
                   'round', 'day', 'cut', 'means', 'include', 'abv', 
                   'system', 'foods', 'service', 'person', 'set', 'site', 
                   'serving','bc', 'e.g', 'word', 'commonly', 'pda', 'offer', 
                   'including', 'living', 'etfs','difference','iso', '4217', 
                   'code', 'form', 'uk',  'immediately', 'safe', 'provide', 
                   'space','hand', 'physical', 'wall', 'time', 'common', 
                   'types', 'collecting', 'shops', 'patterns', 'landing', 
                   'linens', 'item', 'includes', 'theatre', 'magnetic')

NUM_TOPICS_RANGE = c(2:10, 15, 20, 30, 40, 50, 100)
#NUM_TOPICS_RANGE = c(2:4)
NUM_WORDS_TO_GRAPH_PER_TOPIC = 6

productDescriptions = read.csv('./data/wikipediaDefitions.csv', sep=";")

# get (product|description)DF and do some housekeeping
descriptions = productDescriptions %>%
    select(code, augmentedDescription) %>%
    rename(description = augmentedDescription) %>%
    mutate(description = as.character(description)) %>%
    mutate(product = as.factor(as.character(code))) %>%
    select(-code, product, description)

# (product|description)DF ->> (product|word)DF
tidyDescriptions = descriptions %>% 
    unnest_tokens(word, description, token = "words", to_lower = T) %>% 
    filter(!word %in% stop_words$word) %>%
    filter(!word %in% OWN_STOP_WORDS) %>%
    mutate(product = as.factor(product))

# look at word-count distribution per product 
pdf(paste0("output/word-count-per-product/word-count-per-product.pdf"), height=2, width=4)
print(tidyDescriptions %>%
    count(product) %>%
    ggplot() + 
    geom_point(aes(x=product, y=n, color=product), size=0.4) + 
    theme(legend.position = 'none', 
    	axis.text.x=element_blank()))
dev.off()
writeLines(paste0("created output/word-count-per-product/word-count-per-product.pdf"))

#create term document frequencies
descriptions_tdf = tidyDescriptions %>%
  count(product,word) 
  
# #create document term matrix
dtm_descriptions = descriptions_tdf %>%
	cast_dtm(product, word, n)

for(NUM_TOPICS in NUM_TOPICS_RANGE){
  tic(paste0(NUM_TOPICS))
  description_lda = LDA(dtm_descriptions, k = NUM_TOPICS)
  
  # get beta values using tidy function
  description_topics = tidy(description_lda, matrix = "beta")
  
  #graph top NUM_WORDS_TO_GRAPH_PER_TOPIC words in each of the NUM_TOPICS topic 
  top_terms = description_topics %>%
    group_by(topic) %>%
    top_n(NUM_WORDS_TO_GRAPH_PER_TOPIC, beta) %>%
    ungroup() %>%
    arrange(topic, -beta)
  
  pdf(paste0("output/top-words-per-topic/top-",NUM_WORDS_TO_GRAPH_PER_TOPIC,"-words-in-each",NUM_TOPICS,"-topics.pdf"), height=7, width=7)
  print(top_terms %>%
    mutate(term = reorder(term, beta)) %>%
    ggplot(aes(term, beta, fill = factor(topic))) +
    geom_col(show.legend = FALSE) +
    facet_wrap(~ topic, scales = "free") +
    coord_flip() +  theme(axis.title.x=element_blank(),
    axis.text.x=element_blank(),
    axis.ticks.x=element_blank()))
  dev.off()
  writeLines(paste0("output/created top-words-per-topic/top-",NUM_WORDS_TO_GRAPH_PER_TOPIC,"-words-in-each",NUM_TOPICS,"-topics.pdf"))
  
  #gamma: this gives the topic "mixtures" for each document.
  #look at product topic ratios for all products
  pdf(paste0("output/topic-distributions-per-product/",NUM_TOPICS,"-topic-distribution-per-product.pdf"), height=7, width=7)
  print(descriptions %>%
    left_join(tidy(description_lda, matrix = "gamma") %>%
                rename(product=document)) %>% 
    mutate(topic = as.factor(topic)) %>%
    select(product, topic, gamma) %>%
    group_by(product, topic) %>%
    ggplot() + geom_col(aes(x=product, y=gamma, col=topic, fill=topic)) +
    theme(axis.text.y = element_blank()) +
    coord_flip())
  dev.off()
  writeLines(paste0("created output/topic-distributions-per-product/",NUM_TOPICS,"-topic-distribution-per-product.pdf"))
  
  #get topic distributions per product
  gamma_per_product= descriptions %>% 
    left_join(tidy(description_lda, matrix = "gamma") %>%
                rename(product=document)) %>% 
    mutate(topic = as.factor(topic)) %>%
    select(product, topic, gamma) %>%
    ungroup()
  
  #graph number of products associated with each topic by using the max gamma for each product
  pdf(paste0("output/product-distribution-per-topic/product-distribution-per-",NUM_TOPICS,"-topic.pdf"), height=3, width=7)
  print(gamma_per_product %>% 
    group_by(product) %>%
    filter(gamma == max(gamma)) %>%
    arrange(product,topic,gamma) %>%
    ungroup() %>%
    count(topic)  %>%
    ggplot() + theme(legend.position = 'none') +
    geom_col(aes(x= topic, n, fill=topic)))
  dev.off()
  writeLines(paste0("created output/product-distribution-per-topic/product-distribution-per-",NUM_TOPICS,"-topic.pdf"))
  
  #get topic distrubtions in a wide format, i.e. get topics as X's per product 
  #product|topic_1|topic_2|topic_3|etc
  product_topic_distribution = descriptions %>% 
    left_join(tidy(description_lda, matrix = "gamma") %>%
                rename(product=document)) %>% 
    spread(key = topic, value = gamma, sep = "_")
  
  runtime = toc()
  
  save(product_topic_distribution, 
       runtime, 
       NUM_TOPICS, 
       description_lda,
       file=paste0("output/product-topic-distribution-RData/prod_topic_dist_",NUM_TOPICS,".RData"))
  
  writeLines(paste0("created output/product-topic-distribution-RData/prod_topic_dist_",NUM_TOPICS,".RData"))
}




toc()