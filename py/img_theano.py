#%pylab inline
import os
import gzip
import sys
import numpy as np
import pandas as pd
from scipy.misc import imread
from sklearn.metrics import accuracy_score
import six.moves.cPickle as pickle
import timeit
import theano
import theano.tensor as T
from keras.models import Sequential
from keras.layers import Dense
from scipy.misc import imread
from sklearn.metrics import accuracy_score
import tensorflow as tf
import keras
from keras.models import Sequential
import pylab

#loading the MNIST dataset from keras
seed = 128
rng = np.random.RandomState(seed)

# with gzip.open(os.environ['LAV_DIR']+"/log/mnist.pkl.gz", 'rb') as f:
#     try:
#         train_set, valid_set, test_set = pickle.load(f, encoding='latin1')
#     except:
#         train_set, valid_set, test_set = pickle.load(f)


from keras.datasets import mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()
#reshaping the x_train, y_train, x_test and y_test to conform to MLP input and output dimensions
x_train = np.reshape(x_train,(x_train.shape[0],-1))/255.
x_test = np.reshape(x_test,(x_test.shape[0],-1))/255.
y_train = pd.get_dummies(y_train)
y_test = pd.get_dummies(y_test)
#performing one-hot encoding on target variables for train and test
y_train = np.array(y_train)
y_test = np.array(y_test)
#defining model with one input layer[784 neurons], 1 hidden layer[784 neurons] with dropout rate 0.4 and 1 output layer [10 #neurons]
model = Sequential()
model.add(Dense(784,input_dim=784,activation='relu'))
#model.add(Dense(output_dim=50,input_dim=784,activation='relu'))
keras.layers.core.Dropout(rate=0.4)
model.add(Dense(10,input_dim=784,activation='softmax'))
model.compile(loss='categorical_crossentropy', optimizer="adam", metrics=['accuracy'])
# fitting model and performing validation
model.fit(x_train,y_train,epochs=5,batch_size=128,validation_data=(x_test,y_test))

pred = model.predict_classes(x_test)

imgN = 24
img = x_test[imgN]
img = np.reshape(img,(np.sqrt(img.shape[0]),np.sqrt(img.shape[0])))*255
print "Prediction is: ", pred[imgN]
pylab.imshow(img, cmap='gray')
pylab.axis('off')
pylab.show()



