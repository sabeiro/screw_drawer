##devtools::install_github("rstudio/keras")
library(keras)
install_tensorflow()
install_tensorflow(gpu=TRUE)


data<-dataset_mnist()
train_x<-data$train$x
train_y<-data$train$y
test_x<-data$test$x
test_y<-data$test$y
rm(data)

# converting a 2D array into a 1D array for feeding into the MLP and normalising the matrix
train_x <- array(train_x, dim = c(dim(train_x)[1], prod(dim(train_x)[-1]))) / 255
test_x <- array(test_x, dim = c(dim(test_x)[1], prod(dim(test_x)[-1]))) / 255

#converting the target variable to once hot encoded vectors using keras inbuilt function
train_y<-to_categorical(train_y,10)
test_y<-to_categorical(test_y,10)

#defining a keras sequential model
model <- keras_model_sequential()

#defining the model with 1 input layer[784 neurons], 1 hidden layer[784 neurons] with dropout rate 0.4 and 1 output layer[10 neurons]
#i.e number of digits from 0 to 9

model %>%
layer_dense(units = 784, input_shape = 784) %>%
layer_dropout(rate=0.4)%>%
layer_activation(activation = 'relu') %>%
layer_dense(units = 10) %>%
layer_activation(activation = 'softmax')

#compiling the defined model with metric = accuracy and optimiser as adam.
model %>% compile(
loss = 'categorical_crossentropy',
optimizer = 'adam',
metrics = c('accuracy')
)

#fitting the model on the training dataset
model %>% fit(train_x, train_y, epochs = 100, batch_size = 128)

#Evaluating model on the cross validation dataset
loss_and_metrics <- model %>% evaluate(test_x, test_y, batch_size = 128)

#importing the required libraries for the MLP model
import keras
from keras.models import Sequential
import numpy as np

#loading the MNIST dataset from keras
from keras.datasets import mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()

#reshaping the x_train, y_train, x_test and y_test to conform to MLP input and output dimensions
x_train=np.reshape(x_train,(x_train.shape[0],-1))/255
x_test=np.reshape(x_test,(x_test.shape[0],-1))/255

import pandas as pd
y_train=pd.get_dummies(y_train)
y_test=pd.get_dummies(y_test)

#performing one-hot encoding on target variables for train and test
y_train=np.array(y_train)
y_test=np.array(y_test)

#defining model with one input layer[784 neurons], 1 hidden layer[784 neurons] with dropout rate 0.4 and 1 output layer [10 #neurons]
model=Sequential()

from keras.layers import Dense

model.add(Dense(784, input_dim=784, activation='relu'))
keras.layers.core.Dropout(rate=0.4)
model.add(Dense(10,input_dim=784,activation='softmax'))

# compiling model using adam optimiser and accuracy as metric
model.compile(loss='categorical_crossentropy', optimizer="adam", metrics=['accuracy'])
# fitting model and performing validation

model.fit(x_train,y_train,epochs=50,batch_size=128,validation_data=(x_test,y_test))
