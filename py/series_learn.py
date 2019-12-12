import os
import sys
sys.path.append("/home/sabeiro/lav/media/script/py/")
import random
import json
import numpy as np
import scipy, scipy.stats
from scipy.optimize import least_squares
from scipy import stats
import pandas as pd
import requests
from pylab import plot, ylim, xlim, show, xlabel, ylabel
import pylab 
import matplotlib.pyplot as plt
#import statsmodels.formula.api as sm
import statsmodels.api as sm
import statsmodels.formula.api as smf
from statsmodels.graphics.api import qqplot
import sklearn.model_selection as crossval
from sklearn import datasets
from sklearn import svm
from sklearn.model_selection import train_test_split
from sklearn import datasets
from sklearn import svm
from sklearn.model_selection import cross_val_score


baseUrl = "http://analisi.ad.mediamond.it/jsonp.php"
resq = requests.get(baseUrl+"?tab=uominiedonne")
#ser = resq.json()['data'] # x = [row[0] for row in ser]
ser = np.array(resq.json()['data']).astype(np.float)
t = ser[:,0]/1000000000
y = ser[:,1]/1000000
trainD = pd.DataFrame({'t':t,'y':y})
testD = pd.DataFrame({'t':np.linspace(trainD.t[0],trainD.t[trainD.t.size-1]+t[6]-t[0],t.size+7)})

iris = datasets.load_iris()
X_train, X_test, y_train, y_test = crossval.train_test_split(iris.data,iris.target,test_size=0.4,random_state=0)
#X_train, X_test, y_train, y_test = crossval.train_test_split(trainD.t,trainD.y, test_size=0.3, random_state=1)

x_train = sm.add_constant(X_train)
model = sm.OLS(y_train, x_train)
results = model.fit()

clf = svm.SVC(kernel='linear', C=1).fit(X_train, y_train)
clf.score(X_test, y_test)      


clf = svm.SVC(kernel='linear', C=1)
scores = cross_val_score(clf, iris.data, iris.target, cv=5)
print("Accuracy: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))

