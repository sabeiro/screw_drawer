import numpy as np
import theano
from theano.tensor.nnet import conv2d
from theano.tensor.signal import pool
from theano import tensor as T
import numpy as np
from keras.models import Sequential
from keras.layers import Dense
##load
data = np.random.random((1000,100))
labels = np.random.randint(2,size=(1000,1))
model = Sequential()
model.add(Dense(32, activation='relu', input_dim=100))
model.add(Dense(1, activation='sigmoid'))
model.compile(optimizer='rmsprop', loss='binary_crossentropy', metrics=['accuracy'])
model.fit(data,labels,epochs=10,batch_size=32)
predictions = model.predict(data)

from keras.datasets import boston_housing, mnist, cifar10, imdb
from keras.preprocessing import sequence
from keras.utils import to_categorical
from keras.models import Sequential
from keras.layers import Dense
from sklearn.preprocessing import StandardScaler
from keras.layers import Activation, Conv2D, MaxPooling2D, Flatten
from sklearn.model_selection import train_test_split
from urllib2 import urlopen
##picture (number handwritten)
(x_train1,y_train1),(x_test1,y_test1) = mnist.load_data()
num_classes = 10
Y_train1 = to_categorical(y_train1, num_classes)
Y_test1 = to_categorical(y_test1, num_classes)
model = Sequential()
##continuous value
(x_train2,y_train2),(x_test2,y_test2) = boston_housing.load_data()
scaler = StandardScaler().fit(x_train2)
standardized_X = scaler.transform(x_train2)
standardized_X_test = scaler.transform(x_test2)
##pictures rgb
(x_train3,y_train3),(x_test3,y_test3) = cifar10.load_data()
Y_train3 = to_categorical(y_train3, num_classes)
Y_test3 = to_categorical(y_test3, num_classes)
##word sequence
(x_train4,y_train4),(x_test4,y_test4) = imdb.load_data(num_words=20000)
x_train4 = sequence.pad_sequences(x_train4,maxlen=80)
x_test4 = sequence.pad_sequences(x_test4,maxlen=80)
##binary
data = np.loadtxt(urlopen("http://archive.ics.uci.edu/ml/machine-learning-databases/pima-indians-diabetes/pima-indians-diabetes.data"),delimiter=",")
x_train5, x_test5, y_train5, y_test5 = train_test_split(data[:,0:8],data[:,8],test_size=0.33,random_state=42)
##multivariate
data = np.loadtxt(urlopen("http://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-white.csv",delimiter=";")
import seaborn as sns
corr = pd.DataFrame(data).corr()
sns.heatmap(corr,xticklabels=corr.columns.values,yticklabels=corr.columns.values)
plt.show()

x_train6, x_test6, y_train6, y_test6 = train_test_split(data[:,0:8],data[:,8],test_size=0.33,random_state=42)
print '-----loaded------'
print 'pic gray', x_train1.shape  , y_train1.shape, Y_train1.shape
print 'cont val', x_train2.shape , y_train2.shape
print 'pic rgb', x_train3.shape , y_train3.shape
print 'word seq', x_train4.shape , y_train4.shape
print 'binary', x_train5.shape , y_train5.shape
print 'multivariate', x_train6.shape , y_train6.shape

if False:
    for i in range(0,24):
        img = x_train3[i]
        ##img = np.reshape(img,(np.sqrt(img.shape[0]),np.sqrt(img.shape[0])))*255
        pylab.imshow(img, cmap='gray')
        pylab.axis('off')
        pylab.show()

                  

##multi layer perceptron
model.add(Dense(12, input_dim=8, kernel_initializer='uniform', activation='relu'))
model.add(Dense(8, kernel_initializer='uniform', activation='relu'))
model.add(Dense(1, kernel_initializer='uniform', activation='sigmoid'))
model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
model.fit(x_train,y_train,batch_size=32,epochs=15,validation_data=(x_test, y_test))
##multi class
from keras.layers import Dropout
model.add(Dense(512,activation='relu',input_shape=(784,)))
model.add(Dropout(0.2))
model.add(Dense(512,activation='relu'))
model.add(Dropout(0.2))
model.add(Dense(10,activation='softmax'))
model.compile(optimizer='rmsprop', loss='categorical_crossentropy', metrics=['accuracy'])
model.fit(x_train,y_train,batch_size=32,epochs=15,validation_data=(x_test, y_test))
##regression
model.add(Dense(64, activation='relu', input_dim=train_data.shape[1]))
model.add(Dense(1))
model.compile(optimizer='rmsprop', loss='mse', metrics=['mae'])
model.fit(x_train,y_train,batch_size=32,epochs=15,validation_data=(x_test, y_test))
##convolutional
model2 = Sequential()
model2.add(Conv2D(32, (3,3), padding='same', input_shape=x_train.shape[1:]))
model2.add(Activation('relu'))
model2.add(Conv2D(32, (3,3)))
model2.add(Activation('relu'))
model2.add(MaxPooling2D(pool_size=(2,2)))
model2.add(Dropout(0.25))
model2.add(Conv2D(64, (3,3), padding='same'))
model2.add(Activation('relu'))
model2.add(Conv2D(64, (3, 3)))
model2.add(Activation('relu'))
model2.add(MaxPooling2D(pool_size=(2,2)))
model2.add(Dropout(0.25))
model2.add(Flatten())
model2.add(Dense(512))
model2.add(Activation('relu'))
model2.add(Dropout(0.5))
model2.add(Dense(num_classes))
model2.add(Activation('softmax'))
##recurrent
from keras.layers import Embedding,LSTM
model3 = Sequential()
model3.add(Embedding(20000,128))
model3.add(LSTM(128,dropout=0.2,recurrent_dropout=0.2))
model3.add(Dense(1,activation='sigmoid'))
model3.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
model3.fit(x_train4, y_train4, batch_size=32, epochs=15, verbose=1, validation_data=(x_test4, y_test4))
from keras.callbacks import EarlyStopping
early_stopping_monitor = EarlyStopping(patience=2)
model3.fit(x_train4, y_train4, batch_size=32, epochs=15, validation_data=(x_test4, y_test4), callbacks=[early_stopping_monitor])


from keras.optimizers import RMSprop
rmsprop = RMSprop(lr=0.0001)
from keras.optimizers import SGD, RMSprop
sgd = SGD(lr=0.1)


##evaluate
model.output_shape
model.summary()
model.get_config()
model.get_weights()
score = model3.evaluate(x_test, y_test, batch_size=32)

model3.predict(x_test4, batch_size=32)
model3.predict_classes(x_test4,batch_size=32)

from keras.models import load_model
model3.save('model_file.h5')
my_model = load_model('my_model.h5')
##Optimization Parameters
from keras.optimizers import RMSprop
opt = RMSprop(lr=0.0001, decay=1e-6)
model2.compile(loss='categorical_crossentropy', optimizer=opt, metrics=['accuracy'])
##Early Stopping
from keras.callbacks import EarlyStopping
early_stopping_monitor = EarlyStopping(patience=2)




assert image_shape[1] == filter_shape[1]
self.input = input
fan_in = np.prod(filter_shape[1:])
fan_out = (filter_shape[0] * np.prod(filter_shape[2:]) //
                   np.prod(poolsize))
W_bound = np.sqrt(6. / (fan_in + fan_out))
self.W = theano.shared(
    np.asarray(
        rng.uniform(low=-W_bound, high=W_bound, size=filter_shape),
        dtype=theano.config.floatX
    ),
    borrow=True
)

# the bias is a 1D tensor -- one bias per output feature map
b_values = np.zeros((filter_shape[0],), dtype=theano.config.floatX)
self.b = theano.shared(value=b_values, borrow=True)

# convolve input feature maps with filters
conv_out = conv2d(
    input=input,
    filters=self.W,
    filter_shape=filter_shape,
    input_shape=image_shape
)

# pool each feature map individually, using maxpooling
pooled_out = pool.pool_2d(
    input=conv_out,
    ds=poolsize,
    ignore_border=True
)

# add the bias term. Since the bias is a vector (1D array), we first
# reshape it to a tensor of shape (1, n_filters, 1, 1). Each bias will
# thus be broadcasted across mini-batches and feature map
# width & height
self.output = T.tanh(pooled_out + self.b.dimshuffle('x', 0, 'x', 'x'))

# store parameters of this layer
self.params = [self.W, self.b]

# keep track of model input
self.input = input


