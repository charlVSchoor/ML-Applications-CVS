from keras.models import Sequential
from keras.layers.core import Dropout
from keras.layers import Dense, BatchNormalization
from keras.utils import to_categorical
from keras.callbacks import TensorBoard
from keras.optimizers import Adam
from keras import optimizers
from sklearn.preprocessing import LabelEncoder

import numpy as np
import pandas as pd
import csv

from numpy.random import seed
seed(1)

import time
from time import gmtime, strftime

from os import walk

from keras import optimizers

# All parameter gradients will be clipped to
# a maximum norm of 1.
#sgd = optimizers.SGD(lr=0.01, clipnorm=1.)

dataFolder= "./output/data/"
modelDataDirectories = next(walk(dataFolder))[1]

#for model in modelDataDirectories[1]:

models = ['dataFor10', 'dataFor20', 'dataFor7', 'dataFor9', 'dataFor8', 'dataFor6', 'dataFor50', 'dataFor100', 'dataFor40', 'dataFor15', 'dataFor3', 'dataFor30', 'dataFor4', 'dataFor5', 'dataFor2']
#choose which number of topics to run in the model
modelName = models[6]#11 14
#loading data
print("Started @ "+ strftime("%Y-%m-%d %H:%M:%S", gmtime()))
start = time.time()
df_train = pd.read_csv("./output/data/"+modelName+"/training.csv")
df_test = pd.read_csv("./output/data/"+modelName+"/testing.csv")

df_train = df_train.dropna()  
df_train.isnull().sum().sum()

df_test = df_test.dropna()  
df_test.isnull().sum().sum()

#Training data wrangle
x_train_AGE = np.asarray(df_train.iloc[:, 1], np.float32)
x_train_EDUCA = to_categorical(df_train.iloc[:, 2])
label_encoder = LabelEncoder()
integer_encoded_SEX = label_encoder.fit_transform(df_train.iloc[:, 3])

x_train_SEX = to_categorical(integer_encoded_SEX)
x_train_STATE = to_categorical(df_train.iloc[:, 4])
x_train_INCLASS = to_categorical(df_train.iloc[:, 5])
x_train_topics = np.asarray(df_train.iloc[:, 6:], np.float32)

y_train = np.asarray(df_train.iloc[:, 0])
y_train = to_categorical(y_train, 2)

#Testing data wrangle
x_test_AGE = np.asarray(df_test.iloc[:, 1], np.float32)
x_test_EDUCA = to_categorical(df_test.iloc[:, 2])
label_encoder = LabelEncoder()
integer_encoded_SEX = label_encoder.fit_transform(df_test.iloc[:, 3])
x_test_SEX = to_categorical(integer_encoded_SEX)
x_test_STATE = to_categorical(df_test.iloc[:, 4])
x_test_INCLASS = to_categorical(df_test.iloc[:, 5])
x_test_topics = np.asarray(df_test.iloc[:, 6:], np.float32)

y_test = np.asarray(df_test.iloc[:, 0], np.float32)
y_test = to_categorical(y_test, 2)
print(y_test)

#cbinding all the wrangled columns
x_test = np.column_stack((x_test_AGE,x_test_EDUCA, x_test_SEX, x_test_STATE, x_test_INCLASS, x_test_topics))
x_train = np.column_stack((x_train_AGE,x_train_EDUCA, x_train_SEX, x_train_STATE, x_train_INCLASS, x_train_topics))

print("loaded data")
print(time.time() - start)

#set constants
VARIABLES = x_train.shape[1]
TRAINING_ROWS = x_train.shape[0]
DROPOUT_VALUE = 0.3
HIDDEN_LAYER1 = 128
EPOCS = 30
BATCH_SIZE = int(TRAINING_ROWS*0.002)
VALIDATION_SPLIT = 0.1
ACTIVATION_FUNCTION = "sigmoid"

print("VARIABLES {}".format(VARIABLES))
print("TRAINING_ROWS {}".format(TRAINING_ROWS))
print("BATCH_SIZE {}".format(BATCH_SIZE))


LOG_DIR_STR = './runs/{}_run_1l_{}__do_{}__batch_{}__val_{}__epochs_{}__activationFunction_{}'.format(modelName, HIDDEN_LAYER1, str(DROPOUT_VALUE).replace(".",""), BATCH_SIZE, str(VALIDATION_SPLIT).replace(".",""), EPOCS, ACTIVATION_FUNCTION)
print("Writing tensorboard to {}".format(LOG_DIR_STR))

tbCallBack = TensorBoard(log_dir=LOG_DIR_STR, write_graph=False, write_images=False)

model = Sequential()
model.add(Dense(units=HIDDEN_LAYER1, activation=ACTIVATION_FUNCTION, input_dim=VARIABLES))
model.add(BatchNormalization())
model.add(Dropout(DROPOUT_VALUE))
model.add(Dense(units=2, activation='softmax'))
model.compile(loss='binary_crossentropy',
              optimizer='adam',
              metrics=['accuracy'])


#view how many parameters we have to estimate, 
#this is 
print(model.summary())
print(model.layers)

# x_train and y_train are Numpy arrays --just like in the Scikit-Learn API.
model.fit(x_train, y_train, epochs=EPOCS, batch_size=BATCH_SIZE, callbacks=[tbCallBack] ,validation_split=VALIDATION_SPLIT)

loss_and_metrics = model.evaluate(x_test, y_test, batch_size=128)

print(loss_and_metrics)

import csv

csvfile = modelName+"results.csv"

#Assuming res is a flat list
with open(csvfile, "w") as output:
    writer = csv.writer(output, lineterminator='\n')
    for val in loss_and_metrics:
        writer.writerow([val])   