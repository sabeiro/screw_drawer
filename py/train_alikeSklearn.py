#%pylab inline
import os
import gzip
import sys
import numpy as np
import pandas as pd
import scipy as sp
import random
import matplotlib.pyplot as plt
from sklearn.externals import joblib
from sklearn.grid_search import GridSearchCV 
import sklearn.metrics as skm

# seed = 128
# rng = np.random.RandomState(seed)
# random.seed(seed)
dSet_x = pd.read_csv(os.environ['LAV_DIR']+"/log/socio_x.csv.gz",compression='gzip',sep=',',quotechar='"',index_col=0)
dSet_x.fillna(0,inplace=True)
dSet_y = pd.read_csv(os.environ['LAV_DIR']+"/log/socio_y.csv.gz",compression='gzip',sep=',', quotechar='"')
if False: ##M
    dSet_y = dSet_y.ix[:,[1]]
    dSet_y = pd.get_dummies(dSet_y)
    dSet_y = dSet_y.ix[:,[0]]##M
# dSet_y.loc[dSet_y['gender'] == 'M',['gender']] = 1
# dSet_y.loc[dSet_y['gender'] == 'F',['gender']] = 0
if True: ##18-34
    dSet_y = dSet_y.ix[:,[2]]
    dSet_y = pd.get_dummies(dSet_y)
    dSet_y = dSet_y.ix[:,0] + dSet_y.ix[:,2]##18-34

N = dSet_y.shape[0]
shuffleL = random.sample(range(N),N)
partS = [0,int(N*.9),N]
y_train = np.asarray(dSet_y.iloc[shuffleL[partS[0]:partS[1]]],dtype=np.int32)
y_test = np.asarray(dSet_y.iloc[shuffleL[partS[1]:partS[2]]],dtype=np.int32)
x_train = np.asarray(dSet_x.iloc[shuffleL[partS[0]:partS[1]]],dtype=np.int32)
x_test = np.asarray(dSet_x.iloc[shuffleL[partS[1]:partS[2]]],dtype=np.int32)
joblib.dump(x_test,os.environ['LAV_DIR']+"/train/"+'x_test'+'.pkl',compress=1)
joblib.dump(y_test,os.environ['LAV_DIR']+"/train/"+'y_test'+'.pkl',compress=1)
colN = pd.DataFrame(dSet_x.columns)
colN.to_csv(os.environ['LAV_DIR']+"/train/"+'x_test_col'+'.csv')

import sklearn as sk
import sklearn.ensemble
import sklearn.tree
import sklearn.neural_network
import sklearn.svm
import sklearn.gaussian_process
import sklearn.ensemble
import sklearn.naive_bayes
import sklearn.discriminant_analysis
import sklearn.dummy
from sklearn.gaussian_process import GaussianProcessClassifier
from sklearn.gaussian_process.kernels import RBF

h = .02  # step size in the mesh

sData = {'n_estimator':100,"random_state":10,"verbose":0}

classifiers = [
    ##random forest
    sk.ensemble.RandomForestClassifier(n_estimators=100,criterion='entropy',max_features='sqrt',max_depth=5,bootstrap=True,oob_score=True,n_jobs=12,random_state=33)
    ##random forest 2
    ,sk.ensemble.RandomForestClassifier(n_estimators=100,criterion='gini',n_jobs=12,max_depth=15,max_features='auto',min_samples_split=2,random_state=None)
    ##decision tree
    ,sk.tree.DecisionTreeClassifier(criterion="gini",random_state=100,max_depth=10,min_samples_leaf=5)
    ##extra tree
    ,sk.ensemble.ExtraTreesClassifier(bootstrap=False, class_weight=None, criterion='gini',max_depth=None, max_features='auto', max_leaf_nodes=None,min_impurity_split=1e-07, min_samples_leaf=1,min_samples_split=2,min_weight_fraction_leaf=0.0,n_estimators=250,n_jobs=1,oob_score=False,random_state=0,verbose=0,warm_start=False)
    ##dummy variables
    ,sk.dummy.DummyClassifier(strategy='stratified',random_state=10)
    ##logistic regression
    ,sk.linear_model.LogisticRegression(C=100.0,class_weight=None,dual=False,fit_intercept=True,intercept_scaling=1,max_iter=100, multi_class='ovr',n_jobs=12,penalty='l2',random_state=None,solver='liblinear',tol=0.0001,verbose=0,warm_start=False)
    ##gradient boost
    ,sk.ensemble.GradientBoostingClassifier(criterion='friedman_mse',init=None,learning_rate=0.1, loss='deviance', max_depth=3,max_features=None, max_leaf_nodes=None,min_impurity_split=1e-07, min_samples_leaf=1,min_samples_split=2, min_weight_fraction_leaf=0.0,n_estimators=100, presort='auto', random_state=10,subsample=1.0, verbose=0, warm_start=False)
    ##neural network
    ,sk.neural_network.MLPClassifier(activation='logistic', alpha=0.0001, batch_size='auto', beta_1=0.9,beta_2=0.999, early_stopping=False, epsilon=1e-08,hidden_layer_sizes=(100,), learning_rate='constant',learning_rate_init=0.001, max_iter=200, momentum=0.9,nesterovs_momentum=True, power_t=0.5, random_state=None,shuffle=True, solver='adam', tol=0.0001, validation_fraction=0.1,verbose=False, warm_start=False)
    ##support vector
    ,sk.svm.SVC(C=1.0,cache_size=200,class_weight=None,coef0=0.0,decision_function_shape=None,degree=3,gamma='auto',kernel='rbf',max_iter=-1,probability=True,random_state=0,shrinking=True,tol=0.001,verbose=False)
    ##support vector
    ,sk.svm.SVR(kernel='rbf', degree=3, gamma='auto', coef0=0.0, tol=0.001, C=1.0, epsilon=0.1, shrinking=True, cache_size=200, verbose=False, max_iter=-1)
    ##k-neighbors
    ,sk.neighbors.KNeighborsClassifier(algorithm='auto', leaf_size=30, metric='minkowski',metric_params=None, n_jobs=1, n_neighbors=3, p=2,weights='uniform')
    ##gaussian process
    ,sk.gaussian_process.GaussianProcessClassifier(copy_X_train=True,kernel=1**2 * RBF(length_scale=1), max_iter_predict=100,multi_class='one_vs_rest', n_jobs=1, n_restarts_optimizer=0,optimizer='fmin_l_bfgs_b', random_state=None, warm_start=True)
    ##ada boost
    ,sk.ensemble.AdaBoostClassifier(algorithm='SAMME.R', base_estimator=None,learning_rate=1.0, n_estimators=50, random_state=None)
    ##naive bayesias
    ,sk.naive_bayes.GaussianNB(priors=None)
    ##quadratic discriminant
    ,sk.discriminant_analysis.QuadraticDiscriminantAnalysis(priors=None, reg_param=0.0,store_covariances=False, tol=0.0001)
]


modL = pd.read_csv(os.environ['LAV_DIR']+"train/modelSelection.csv")
for index, row in modL.iterrows():
    if not row['state']:
        continue
    print row['model']
    clf = classifiers[index]
    model = clf.fit(x_train,y_train.ravel())
    joblib.dump(model,os.environ['LAV_DIR']+"/train/"+'lookAlike'+str(index)+'.pkl',compress=1)
    print 'done'
    

if False: ##single trial
    clf = sk.ensemble.GradientBoostingClassifier(criterion='friedman_mse',init=None,learning_rate=0.1,loss='deviance', max_depth=3,max_features=None,max_leaf_nodes=None,min_impurity_split=1e-07,min_samples_leaf=1,min_samples_split=2, min_weight_fraction_leaf=0.0,n_estimators=100, presort='auto', random_state=10,subsample=1.0, verbose=0, warm_start=False)
    model = clf.fit(x_train,y_train.ravel())
    fpr, tpr, _ = skm.roc_curve(y_test,model.predict_proba(x_test)[:,1])
    roc_auc = skm.auc(fpr,tpr)## = np.trapz(fpr,tpr)
    fsc = skm.f1_score(y_test,model.predict(x_test))
    acc = skm.accuracy_score(y_test,model.predict(x_test))
    plt.clf()
    plt.plot([0, 1],[0, 1],'k--',label="model | auc  fsc  acc")
    plt.plot(fpr,tpr,label='%s | %0.2f %0.2f %0.2f ' % (row['model'],roc_auc,fsc,acc))
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.0])
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('Receiver operating characteristic')
    plt.legend(loc="lower right",prop={'size':12})#,'family':'monospace'})
    plt.show()



if False:    
    print 'grid grad boost'
    param_test1 = {'n_estimators':range(20,81,10)}
    param_test2 = {'max_depth':range(5,16,2), 'min_samples_split':range(200,1001,200)}
    param_test3 = {'min_samples_split':range(1000,2100,200),'min_samples_leaf':range(30,71,10)}
    param_test4 = {'max_features':range(7,20,2)}
    param_test5 = {'subsample':[0.6,0.7,0.75,0.8,0.85,0.9]}
    gsearch1 = GridSearchCV(
        estimator=sk.ensemble.GradientBoostingClassifier(learning_rate=0.1,min_samples_split=500,min_samples_leaf=50,max_depth=8,max_features='sqrt',subsample=0.8,random_state=10)
        ,param_grid=param_test1,scoring='roc_auc',n_jobs=4,iid=False,cv=5)
    # model = gsearch1.fit(x_train,y_train.ravel())
    # joblib.dump(model,os.environ['LAV_DIR']+"/train/"+'lookAlike'+str(5)+'.pkl',compress=1)

    
    skm.cross_val_score(clf,x_train,y_train,scoring='neg_log_loss')
    print "Confusion matrix " , skm.confusion_matrix(y_test,model.predict(x_test))
    
    from sklearn.metrics import fbeta_score, make_scorer
    ftwo_scorer = make_scorer(fbeta_score,beta=2)
    grid = GridSearchCV(sk.svm.LinearSVC(),param_grid={'C':[1,10]},scoring=ftwo_scorer)
    def my_custom_loss_func(ground_truth,predictions):
        diff = np.abs(ground_truth - predictions).max()
        return np.log(1 + diff)
    score = make_scorer(my_custom_loss_func,greater_is_better=True)
    print score(model,x_train,y_train.ravel())

