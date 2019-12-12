import os
import gzip
import sys
import numpy as np
import pandas as pd
import scipy as sp
import random
import matplotlib.pyplot as plt
from sklearn.externals import joblib
from treeinterpreter import treeinterpreter as ti
import sklearn as sk
import sklearn.metrics as skm
import sklearn.tree as skt
from sklearn import cross_validation, metrics 


x_test = joblib.load(os.environ['LAV_DIR']+"/train/"+'x_test'+'.pkl')
y_test = joblib.load(os.environ['LAV_DIR']+"/train/"+'y_test'+'.pkl')

modL = pd.read_csv(os.environ['LAV_DIR']+"train/modelSelection.csv")
colN = pd.read_csv(os.environ['LAV_DIR']+"/train/"+'x_test_col'+'.csv')['0']
model = dict()
impL = pd.DataFrame(index=colN)

plt.clf()
plt.plot([0, 1],[0, 1],'k--',label="model | auc  fsc  acc")
for index, row in modL.iterrows():
    if not row['state']:
        continue
    print row['model']
    fName = os.environ['LAV_DIR']+"train/"+'lookAlike'+str(index)+'.pkl'
    if not os.path.isfile(fName):
        continue
    model[index] = joblib.load(fName)
    fpr, tpr, _ = skm.roc_curve(y_test,model[index].predict_proba(x_test)[:,1])
    roc_auc = skm.auc(fpr,tpr)## = np.trapz(fpr,tpr)
    fsc = skm.f1_score(y_test,model[index].predict(x_test))
    acc = skm.accuracy_score(y_test,model[index].predict(x_test))
    ##cv_score = cross_validation.cross_val_score(model[i],x_train,y_train.ravel(),cv=5,scoring='roc_auc')
    plt.plot(fpr,tpr,label='%s | %0.2f %0.2f %0.2f ' % (row['model'],roc_auc,fsc,acc))
    rf = model[index]
    if not hasattr(rf,'feature_importances_'):
        continue
    importances = pd.DataFrame({'feature':colN,'importance':np.round(rf.feature_importances_,3)})
    importances = importances.sort_values('importance',ascending=False).set_index('feature')
    impL[row['model']] = importances
    ##importances.plot.bar()

plt.xlim([0.0, 1.0])
plt.ylim([0.0, 1.0])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('Receiver operating characteristic')
plt.legend(loc="lower right",prop={'size':12})#,'family':'monospace'})
plt.savefig(os.environ['LAV_DIR']+'intertino/fig/modelPerformaces.jpg')
plt.show()

impL['sum'] = impL.sum(axis=1)
impL = impL.sort_values(['sum'],ascending=[False])
impL.to_csv(os.environ['LAV_DIR']+"/train/"+'feature_sel'+'.csv')

y_prob = model[5].predict_proba(x_test)[:,1]
y_pred = np.asarray([x for x in y_prob],dtype=np.float32)
thMod = [x*0.05+0.5 for x in range(11)]
accL = []
for th in thMod:
    thSet = y_prob>=th 
    y_pred[thSet] = 1
    y_pred[thSet==False] = 0
    if thSet.sum() == 0 :
        continue
    accL.append([th,skm.accuracy_score(y_test,y_pred),skm.accuracy_score(y_test[thSet],y_pred[thSet]),float(2*thSet.sum())/y_test.shape[0]])

xnew = np.arange(min([x[0] for x in accL]),max([x[0] for x in accL]),0.005) 
y_reach = sp.interpolate.interp1d([x[0] for x in accL],[x[3] for x in accL])(xnew)
f_reach_inv = sp.interpolate.interp1d([x[3] for x in accL],[x[0] for x in accL])(y_reach)
y_acc = sp.interpolate.interp1d([x[0] for x in accL],[x[2] for x in accL])(f_reach_inv)
plt.plot(100.*y_reach,y_acc,'-k',label='acc1')
plt.xlabel('reach %')
plt.ylabel('accuracy')
plt.title("male classification")
plt.legend()
plt.show()

