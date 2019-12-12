#%pylab inline
import os
import gzip
import sys
import numpy as np
import pandas as pd
from scipy.misc import imread
from sklearn.metrics import accuracy_score
from sklearn.metrics import confusion_matrix
import six.moves.cPickle as pickle
import timeit
import theano
import theano.tensor as T
from keras.models import Sequential
from keras.layers import Dense
from scipy import interpolate
import tensorflow as tf
import keras
import pylab
import random
import matplotlib.pyplot as plt
from sklearn.metrics import roc_curve, auc
from sklearn.externals import joblib
from keras.models import model_from_json
import h5py

seed = 128
rng = np.random.RandomState(seed)

dSet_x = pd.read_csv(os.environ['LAV_DIR']+"/log/socio_x.csv.gz", compression='gzip', sep=',',quotechar='"',index_col=0)
dSet_x.fillna(0,inplace=True)
dSet_y = pd.read_csv(os.environ['LAV_DIR']+"/log/socio_y.csv.gz", compression='gzip', sep=',', quotechar='"')
dSet_y = dSet_y.ix[:,[1]]
dSet_y = pd.get_dummies(dSet_y)
dSet_y = dSet_y.ix[:,[0]]##M

# X_train = X_train.astype(theano.config.floatX) 
# X_test = X_test.astype(theano.config.floatX)
# dSet_y.loc[dSet_y['gender'] == 'M',['gender']] = 1
# dSet_y.loc[dSet_y['gender'] == 'F',['gender']] = 0

N = dSet_y.shape[0]
shuffleL = random.sample(range(N),N)

partS = [0,int(N*.9),N,N]
y_train = np.asarray(dSet_y.iloc[shuffleL[partS[0]:partS[1]]],dtype=np.int32)
y_test = np.asarray(dSet_y.iloc[shuffleL[partS[1]:partS[2]]],dtype=np.int32)
# y_valid = np.asarray(dSet_y.iloc[shuffleL[partS[2]:partS[3]]],dtype=np.int32)
x_train = np.asarray(dSet_x.iloc[shuffleL[partS[0]:partS[1]]],dtype=np.int32)
x_test = np.asarray(dSet_x.iloc[shuffleL[partS[1]:partS[2]]],dtype=np.int32)
# x_valid = np.asarray(dSet_x.iloc[shuffleL[partS[2]:partS[3]]],dtype=np.int32)

Nent = y_train.shape[0]
Nneu = x_train.shape[1]
Ncat = y_train.shape[1]

model = Sequential()
model.add(Dense(input_dim=Nneu,output_dim=Nneu,activation='tanh',init="uniform"))
keras.layers.core.Dropout(rate=0.15)
model.add(Dense(input_dim=Nneu,output_dim=Nneu,activation='tanh',init="uniform"))
keras.layers.core.Dropout(rate=0.15)
model.add(Dense(input_dim=Nneu,output_dim=Ncat,activation='sigmoid',init="uniform"))
#model.compile(loss='categorical_crossentropy',optimizer="adam",metrics=['accuracy'])
sgd = keras.optimizers.SGD(lr=0.001,decay=1e-7,momentum=.9)
#model.compile(loss='mean_squared_error',optimizer=sgd,metrics=['accuracy'])
model.compile(loss='binary_crossentropy',optimizer='sgd',metrics=['accuracy'])
model.fit(x_train,y_train,epochs=25,batch_size=128,validation_data=(x_test,y_test))

fName = os.environ['LAV_DIR']+"/train/"+'lookAlikeNeural'+str(0)
model_json = model.to_json()
with open(fName+".json", "w") as json_file:
    json_file.write(model_json)
model.save_weights(fName+".h5")

##predictions = model.predict(X)





##svm
##bagging classifier
##n estim 10
##max feat 1/10
##kernel lin
##deg 3
##C 1



pred = model.predict_classes(x_valid)
print pred

net1 = NeuralNet(
    layers=[('input',layers.InputLayer),
            ('hidden',layers.DenseLayer),
            ('output',layers.DenseLayer),
    ],
    input_shape=(None,Ncat),
    hidden_num_units=3,  # number of units in 'hidden' layer
    output_nonlinearity=lasagne.nonlinearities.softmax,
    output_num_units=10,  # 10 target values for the digits 0, 1, 2, ..., 9
    # optimization method:
    update=nesterov_momentum,
    update_learning_rate=0.01,
    update_momentum=0.9,
        max_epochs=10,
        verbose=1,
    )

net1.fit(x_train,y_train)
print("Predicted: %s" % str(net1.predict(x_test)))



imgN = 24
img = x_test[imgN]
img = np.reshape(img,(np.sqrt(img.shape[0]),np.sqrt(img.shape[0])))*255
print "Prediction is: ", pred[imgN]
pylab.imshow(img, cmap='gray')
pylab.axis('off')
pylab.show()


