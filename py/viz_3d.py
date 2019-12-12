import os
import gzip
import sys
import numpy as np
import pandas as pd
import csv
from numpy import mean,cov,double,cumsum,dot,linalg,array,rank,std,argsort
from pylab import plot,subplot,axis,stem,show,figure
from numpy.linalg import eigh, solve
from numpy.random import randn
##from sklearn.decomposition import PCA
from matplotlib.mlab import PCA
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

A = array([ [2.4,0.7,2.9,2.2,3.0,2.7,1.6,1.1,1.6,0.9],
            [2.5,0.5,2.2,1.9,3.1,2.3,2,1,1.5,1.1] ])
A = np.array([
    [0, 1 ,0 ,0],
    [0, 0, 1, 0],
    [0, 1, 1, 0],
    [1, 0, 0, 1]
])
A = np.array(np.random.randint(10,size=(10,3)))
##A = array([randn(8) for k in range(150)])
M = (A-mean(A.T,axis=1)).T 
[latent,coeff] = linalg.eig(cov(M)) 
score = dot(coeff.T,M)

result = PCA(A)


plt.close('all') 
fig1 = plt.figure() 
ax = Axes3D(fig1) 
ax.scatter(result.Y[:,0],result.Y[:,1],result.Y[:,2],'bo')
xAxisLine = ((min(result.Y[:,0]), max(result.Y[:,0])), (0, 0), (0,0))
ax.plot(xAxisLine[0], xAxisLine[1], xAxisLine[2], 'r')
yAxisLine = ((0, 0), (min(result.Y[:,1]), max(result.Y[:,1])), (0,0))
ax.plot(yAxisLine[0], yAxisLine[1], yAxisLine[2], 'r')
zAxisLine = ((0, 0), (0,0), (min(result.Y[:,2]), max(result.Y[:,2])))
ax.plot(zAxisLine[0], zAxisLine[1], zAxisLine[2], 'r')
ax.set_xlabel("x-axis label") 
ax.set_ylabel("y-axis label")
ax.set_zlabel("y-axis label")
ax.set_title("The title of the plot")
plt.show() 


figure()
subplot(121)
m = mean(A,axis=1)
plot([0, -coeff[0,0]*2]+m[0], [0, -coeff[0,1]*2]+m[1],'--k')
plot([0, coeff[1,0]*2]+m[0], [0, coeff[1,1]*2]+m[1],'--k')
plot(A[0,:],A[1,:],'ob') # the data
axis('equal')
subplot(122)
plot(score[0,:],score[1,:],'*g')
axis('equal')
show()

import sympy 
reduced_form, inds = sympy.Matrix(A.values).rref()
reduced_form
print inds

lambdas, V =  np.linalg.eig(A.T)
print A[lambdas == 0,:]
Q, R = sp.linalg.qr(A)
