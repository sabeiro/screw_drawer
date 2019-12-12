##https://www.aaai.org/ocs/index.php/WS/AAAIW15/paper/viewFile/10179/10251
import os
import sys
import random
import numpy as np
import pandas as pd
import pylab 
import matplotlib.pyplot as plt
import series_lib as sl
import db_sql as dbs
import datetime
import calendar
import string
import json
from scipy import signal as sg


todayD = datetime.datetime.today()
todayD = todayD.replace(hour=0,minute=0,second=0,microsecond=0)
yesterdayD = todayD - datetime.timedelta(days=1)

startC = {}
with open(os.environ['LAV_DIR']+"/train/series_interp.json") as f:
    startC = json.load(f)

resqW = pd.DataFrame()
nAhead = 14 + datetime.datetime.today().weekday()
nr = sorted(startC.keys(),key=lambda x:x[0])[0]
print '-------------------' + nr + '--------------------------'
sData = {'tab':'daily','sect':nr}
sDay, sWeek, sMonth = sl.getSeries({'tab':'daily','sect':nr})
""" transform into polar coordinates """
sDay['x'] = ( (sDay['y'] - sDay['y'].max()) + (sDay['y'] - sDay['y'].min()) ) / (sDay['y'].max() - sDay['y'].min())
sDay['phi'] = 2.*np.arccos(sDay['x'])
sDay['r'] = [float(x)/sDay.shape[0] for x in range(sDay.shape[0])]
if False:
    ax = plt.subplot(111, projection='polar')
    ax.plot(sDay['phi'],sDay['r'])
    ax.grid(True)
    ax.set_title("A line plot on a polar axis", va='bottom')
    plt.show()

def innerP(x,y):
    #return np.tensordot(x,y,axes=(-1,-1))
    return x*y - np.sqrt(1-x**2)*np.sqrt(1-y**2)

nSet = sDay.shape[0]
angField = np.matrix([[innerP(i,j) for j in sDay['x']] for i in sDay['x']])

quant = np.percentile(sDay['x'],[x for x in range(0,105,5)])
sDay['quant'] =  pd.cut(sDay['x'],bins=quant,labels=range(len(quant)-1),right=True,include_lowest=True)
""" adjacent matrix - graph representation """
markovMat = np.matrix([[0. for i in xrange(len(quant))] for i in xrange(len(quant))])
timeStep = 1
for x in range(nSet-timeStep):
    i = sDay['quant'][x]
    j = sDay['quant'][x+timeStep]
    markovMat[i,j] += 1.

markovMat = markovMat/markovMat.sum()
markovField = np.matrix([[0. for i in xrange(nSet)] for i in xrange(nSet)])
for i in range(nSet):
    for j in range(nSet):
        ii = sDay['quant'][i]
        jj = sDay['quant'][j]
        markovField[i,j] += markovMat[ii,jj]

markovBlur = np.matrix([[0. for i in xrange(nSet/2)] for i in xrange(nSet/2)])
for i in range(nSet/2):
    for j in range(nSet/2):
        markovBlur[i,j] = (markovField[2*i,2*j] + markovField[2*i+1,2*j] + markovField[2*i,2*j+1] + markovField[2*i+1,2*j+1])/4


#markovF = sg.convolve(markovMat,fGaussBlur)

if False:
    sMat = angField
    plt.imshow(sMat, interpolation='nearest', cmap=plt.cm.ocean, extent=(0.5,10.5,0.5,10.5))
    plt.colorbar()
    plt.show()



    
import theano
from theano import tensor as T
from theano.tensor.nnet import conv2d
rng = np.random.RandomState(23455)

# instantiate 4D tensor for input
input = T.tensor4(name='input')

# initialize shared variable for weights.
w_shp = (2, 3, 9, 9)
w_bound = np.sqrt(3 * 9 * 9)
W = theano.shared(np.asarray(rng.uniform(low=-1.0 / w_bound,high=1.0 / w_bound,size=w_shp),dtype=input.dtype), name ='W')
b_shp = (2,)
b = theano.shared(np.asarray(rng.uniform(low=-.5, high=.5, size=b_shp),dtype=input.dtype),name ='b')
conv_out = conv2d(input, W)
output = T.nnet.sigmoid(conv_out + b.dimshuffle('x', 0, 'x', 'x'))
f = theano.function([input], output)

import pylab
import os
from PIL import Image

# open random image of dimensions 639x516
img = Image.open(open(os.environ['LAV_DIR'] + 'fig/bottegaVeneta.jpg'))
# dimensions are (height, width, channel)
img = np.asarray(img, dtype='float64') / 256.
# put image in 4D tensor of shape (1, 3, height, width)
img_ = img.transpose(2, 0, 1).reshape(1, 3, 750,500)
filtered_img = f(img_)
# plot original image and first and second components of output
pylab.subplot(1, 3, 1); pylab.axis('off'); pylab.imshow(img)
pylab.gray();
# recall that the convOp output (filtered image) is actually a "minibatch",
# of size 1 here, so we take index 0 in the first dimension:
pylab.subplot(1, 3, 2); pylab.axis('off'); pylab.imshow(filtered_img[0, 0, :, :])
pylab.subplot(1, 3, 3); pylab.axis('off'); pylab.imshow(filtered_img[0, 1, :, :])
pylab.show()

from theano.tensor.signal import pool

input = T.dtensor4('input')
maxpool_shape = (2, 2)
pool_out = pool.pool_2d(input, maxpool_shape, ignore_border=True)
f = theano.function([input],pool_out)

invals = np.random.RandomState(1).rand(3, 2, 5, 5)
print 'With ignore_border set to True:'
print 'invals[0, 0, :, :] =\n', invals[0, 0, :, :]
print 'output[0, 0, :, :] =\n', f(invals)[0, 0, :, :]

pool_out = pool.pool_2d(input, maxpool_shape, ignore_border=False)
f = theano.function([input],pool_out)
print 'With ignore_border set to False:'
print 'invals[1, 0, :, :] =\n ', invals[1, 0, :, :]
print 'output[1, 0, :, :] =\n ', f(invals)[1, 0, :, :]


x = T.matrix('x')   # the data is presented as rasterized images
y = T.ivector('y')  # the labels are presented as 1D vector of
# [int] labels

######################
# BUILD ACTUAL MODEL #
######################
import series_convNeur as sneu
sneu = reload(sneu)

print('... building the model')
batch_size = 52
layer0_input = x.reshape((batch_size, 1, 28, 28))

nkerns = [4,4,4,4]

layer0 = sneu.LeNetConvPoolLayer(
    rng,
    input=layer0_input,
    image_shape=(batch_size, 1, 28, 28),
    filter_shape=(nkerns[0], 1, 5, 5),
    poolsize=(2, 2)
)

# Construct the second convolutional pooling layer
# filtering reduces the image size to (12-5+1, 12-5+1) = (8, 8)
# maxpooling reduces this further to (8/2, 8/2) = (4, 4)
# 4D output tensor is thus of shape (batch_size, nkerns[1], 4, 4)
layer1 = sneu.LeNetConvPoolLayer(
    rng,
    input=layer0.output,
    image_shape=(batch_size, nkerns[0], 12, 12),
    filter_shape=(nkerns[1], nkerns[0], 5, 5),
    poolsize=(2, 2)
)

# the HiddenLayer being fully-connected, it operates on 2D matrices of
# shape (batch_size, num_pixels) (i.e matrix of rasterized images).
# This will generate a matrix of shape (batch_size, nkerns[1] * 4 * 4),
# or (500, 50 * 4 * 4) = (500, 800) with the default values.
layer2_input = layer1.output.flatten(2)

# construct a fully-connected sigmoidal layer
layer2 = HiddenLayer(
    rng,
    input=layer2_input,
    n_in=nkerns[1] * 4 * 4,
    n_out=500,
    activation=T.tanh
)

# classify the values of the fully-connected sigmoidal layer
layer3 = LogisticRegression(input=layer2.output, n_in=500, n_out=10)

# the cost we minimize during training is the NLL of the model
cost = layer3.negative_log_likelihood(y)

# create a function to compute the mistakes that are made by the model
test_model = theano.function(
    [index],
    layer3.errors(y),
    givens={
        x: test_set_x[index * batch_size: (index + 1) * batch_size],
        y: test_set_y[index * batch_size: (index + 1) * batch_size]
    }
)

validate_model = theano.function(
    [index],
    layer3.errors(y),
    givens={
        x: valid_set_x[index * batch_size: (index + 1) * batch_size],
        y: valid_set_y[index * batch_size: (index + 1) * batch_size]
    }
)

# create a list of all model parameters to be fit by gradient descent
params = layer3.params + layer2.params + layer1.params + layer0.params

# create a list of gradients for all model parameters
grads = T.grad(cost, params)

# train_model is a function that updates the model parameters by
# SGD Since this model has many parameters, it would be tedious to
# manually create an update rule for each model parameter. We thus
# create the updates list by automatically looping over all
# (params[i], grads[i]) pairs.
updates = [
    (param_i, param_i - learning_rate * grad_i)
    for param_i, grad_i in zip(params, grads)
]

train_model = theano.function(
    [index],
    cost,
    updates=updates,
    givens={
        x: train_set_x[index * batch_size: (index + 1) * batch_size],
        y: train_set_y[index * batch_size: (index + 1) * batch_size]
    }
)
