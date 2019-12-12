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

learning_rate=0.13
n_epochs=1000
batch_size=600

with gzip.open(os.environ['LAV_DIR']+"/log/mnist.pkl.gz", 'rb') as f:
    train_set, valid_set, test_set = pickle.load(f)

train_set_x, train_set_y = train_set
valid_set_x, valid_set_y = valid_set
test_set_x, test_set_y = test_set
n_train_batches = train_set_x.shape[0] // batch_size
n_valid_batches = valid_set_x.shape[0]// batch_size
n_test_batches = test_set_x.shape[0] // batch_size

index = T.lscalar()  # index to a [mini]batch
x = T.matrix('x')  # data, presented as rasterized images
y = T.ivector('y')  # labels, presented as 1D vector of [int] labels

n_in = 28*28
n_out = 10
W = theano.shared(value=np.zeros((n_in,n_out),dtype=theano.config.floatX),name='W',borrow=True)
b = theano.shared(value=np.zeros((n_out,),dtype=theano.config.floatX),name='b',borrow=True)
p_y_given_x = T.nnet.softmax(T.dot(x,W)+b)
y_pred = T.argmax(p_y_given_x, axis=1)
params = [W,b]

def negative_log_likelihood(p_y_given_x,y):
    return -T.mean(T.log(p_y_given_x)[T.arange(y.shape[0]), y])

def errors(x,W,b,y):
    if y.dtype.startswith('int'):
        p_y_given_x = T.nnet.softmax(T.dot(x,W) + b)
        y_pred = T.argmax(p_y_given_x, axis=1)
        return T.mean(T.neq(y_pred, y))
    else:
        raise NotImplementedError()

cost = negative_log_likelihood(p_y_given_x,y)

test_model = theano.function(inputs=[index],outputs=errors(x,W,b,y),givens={
    x:test_set_x[index*batch_size:(index+1)*batch_size],
    W:W,b:b,
    y:test_set_y[index*batch_size:(index+1)*batch_size]})

validate_model = theano.function(inputs=[index],outputs=errors(y_pred,y),givens={
    x:valid_set_x[index*batch_size:(index+1)*batch_size],
    y:valid_set_y[index*batch_size:(index+1)*batch_size]})

g_W = T.grad(cost=cost,wrt=W)
g_b = T.grad(cost=cost,wrt=b)

updates = [(W,W-learning_rate*g_W),(b,b-learning_rate*g_b)]

train_model = theano.function(inputs=[index],outputs=cost,updates=updates,givens={
    x:train_set_x[index*batch_size:(index+1)*batch_size],
    y:train_set_y[index*batch_size:(index+1)*batch_size]})

patience = 5000  # look as this many examples regardless
patience_increase = 2  # wait this much longer when a new best is
improvement_threshold = 0.995  # a relative improvement of this much is
validation_frequency = min(n_train_batches, patience // 2)
best_validation_loss = numpy.inf
test_score = 0.
start_time = timeit.default_timer()

done_looping = False
epoch = 0
while (epoch < n_epochs) and (not done_looping):
    epoch = epoch + 1
    for minibatch_index in range(n_train_batches):
        minibatch_avg_cost = train_model(minibatch_index)
        iter = (epoch - 1) * n_train_batches + minibatch_index
        if (iter + 1) % validation_frequency == 0:
            validation_losses = [validate_model(i) for i in range(n_valid_batches)]
            this_validation_loss = numpy.mean(validation_losses)
            print('epoch %i, minibatch %i/%i, validation error %f %%' %
                (epoch,minibatch_index + 1,n_train_batches,this_validation_loss * 100.))
            if this_validation_loss < best_validation_loss:
                if this_validation_loss < best_validation_loss *  \
                   improvement_threshold:
                    patience = max(patience, iter * patience_increase)
                    
                best_validation_loss = this_validation_loss
                test_losses = [test_model(i) for i in range(n_test_batches)]
                test_score = numpy.mean(test_losses)
                print(('     epoch %i, minibatch %i/%i, test error of best model %f %%') % (epoch,minibatch_index + 1,n_train_batches,test_score * 100.))
                
                # save the best model
                with open('best_model.pkl', 'wb') as f:
                    pickle.dump(classifier, f)
                    
            if patience <= iter:
                done_looping = True
                break
