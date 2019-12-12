#!/usr/bin/env python
import numpy as np
import sklearn
import matplotlib as plt


def nonlin(x):
    return 1/(1+np.exp(-x))
def nonlin_der(x):
    return x*(1-x)

def basicNeural(X,y):
    np.random.seed(1)
    # randomly initialize our weights with mean 0
    W0 = 2*np.random.random((3,4)) - 1
    w1 = 2*np.random.random((4,1)) - 1
    for j in xrange(60000):
        l0 = X
        L1 = nonlin(np.dot(l0,W0))
        l2 = nonlin(np.dot(L1,w1))
        l2_error = y - l2
        if (j%10000) == 0:
            print "Error:" + str(np.mean(np.abs(l2_error)))
        l2_delta = l2_error*nonlin_der(l2)
        L1_error = l2_delta.dot(w1.T)
        L1_delta = L1_error*nonlin_der(L1)
        w1 += L1.T.dot(l2_delta)
        W0 += l0.T.dot(L1_delta)
    return W0,w1

def basicPred(v1,W0,w1):
    v2 = nonlin(np.dot(L1,v1))
    print v2
X = np.array([[0,0,1],[0,1,1],[1,0,1],[1,1,1]])
y = np.array([[0],[1],[1],[0]])
W0,w1 = basicNeural(X,y)
v1 = [1,0,0,0]
v1 = X[:,0]
t1 = np.array([[1],[0],[0]])
print np.dot(t1.T,X.T)
print v1
print L1.dot(X[:,1])

def nonlin(x):
    return np.tanh(x)
def nonlin_der(x):
    return 1-np.tanh(x)**2

# Helper function to evaluate the total loss on the dataset
def calculate_loss(X,y,model):
    reg_lambda = 0.01 # regularization strength
    W1, b1, W2, b2 = model['W1'], model['b1'], model['W2'], model['b2']
    # Forward propagation to calculate our predictions
    z1 = X.dot(W1) + b1
    a1 = nonlin(z1)
    z2 = a1.dot(W2) + b2
    exp_scores = np.exp(z2)
    probs = exp_scores / np.sum(exp_scores,axis=1,keepdims=True)
    # Calculating the loss
    corect_logprobs = -np.log(probs[range(len(X)), y])
    data_loss = np.sum(corect_logprobs)
    # Add regulatization term to loss (optional)
    data_loss += reg_lambda/2 * (np.sum(np.square(W1)) + np.sum(np.square(W2)))
    return 1./len(X) * data_loss

# Helper function to predict an output (0 or 1)
def predict(model, x):
    W1, b1, W2, b2 = model['W1'], model['b1'], model['W2'], model['b2']
    # Forward propagation
    z1 = x.dot(W1) + b1
    a1 = nonlin(z1)
    z2 = a1.dot(W2) + b2
    exp_scores = np.exp(z2)
    probs = exp_scores / np.sum(exp_scores, axis=1, keepdims=True)
    return np.argmax(probs, axis=1)

# This function learns parameters for the neural network and returns the model.
# - nn_hdim: Number of nodes in the hidden layer
# - num_passes: Number of passes through the training data for gradient descent
# - print_loss: If True, print the loss every 1000 iterations
def build_model(X,y,nn_hdim, num_passes=20000, print_loss=False):
    reg_lambda = 0.01 # regularization strength
    epsilon = 0.01 # learning rate for gradient descent
    nn_input_dim = 2 # input layer dimensionality
    nn_output_dim = 2 # output layer dimensionality
    # Gradient descent parameters (I picked these by hand)
    # Initialize the parameters to random values. We need to learn these.
    np.random.seed(0)
    W1 = np.random.randn(nn_input_dim, nn_hdim) / np.sqrt(nn_input_dim)
    b1 = np.zeros((1, nn_hdim))
    W2 = np.random.randn(nn_hdim, nn_output_dim) / np.sqrt(nn_hdim)
    b2 = np.zeros((1, nn_output_dim))
    # This is what we return at the end
    model = {}
    # Gradient descent. For each batch...
    for i in xrange(0, num_passes):
        # Forward propagation
        z1 = X.dot(W1) + b1
        a1 = nonlin(z1)
        z2 = a1.dot(W2) + b2
        exp_scores = np.exp(z2)
        probs = exp_scores / np.sum(exp_scores, axis=1, keepdims=True)
        # Backpropagation
        delta3 = probs
        delta3[range(len(X)), y] -= 1
        dW2 = (a1.T).dot(delta3)
        db2 = np.sum(delta3, axis=0, keepdims=True)
        delta2 = delta3.dot(W2.T) * nonlin_der(z1)#(1 - np.power(a1, 2))
        dW1 = np.dot(X.T, delta2)
        db1 = np.sum(delta2, axis=0)
        # Add regularization terms (b1 and b2 don't have regularization terms)
        dW2 += reg_lambda * W2
        dW1 += reg_lambda * W1
        # Gradient descent parameter update
        W1 += -epsilon * dW1
        b1 += -epsilon * db1
        W2 += -epsilon * dW2
        b2 += -epsilon * db2
        # Assign new parameters to the model
        model = { 'W1': W1, 'b1': b1, 'W2': W2, 'b2': b2}
        # Optionally print the loss.
        # This is expensive because it uses the whole dataset, so we don't want to do it too often.
        if print_loss and i % 1000 == 0:
          print "Loss after iteration %i: %f" %(i, calculate_loss(X,y,model))
     
    return model

