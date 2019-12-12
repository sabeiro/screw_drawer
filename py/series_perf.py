import os
import sys
import random
import numpy as np
import scipy as sp
import pandas as pd
from scipy import stats
import pylab 
import matplotlib.pyplot as plt
#import statsmodels.formula.api as sm
import statsmodels.tsa as tsa
import sklearn.model_selection as crossval
import series_lib as sl
import db_sql as dbs
import datetime
import calendar
import string
import json

print '-----------------------series-perf--------------------------------'

todayD = datetime.datetime.today()
todayD = todayD.replace(hour=0,minute=0,second=0,microsecond=0)
yesterdayD = todayD - datetime.timedelta(days=1)

startC = {}
with open(os.environ['LAV_DIR']+"/train/series_interp.json") as f:
    startC = json.load(f)

predD = pd.DataFrame()
predW = pd.DataFrame()
resS = {}
resqW = pd.DataFrame()
nAhead = 14 + datetime.datetime.today().weekday()
nr = names[1]
for nr in startC.keys():
    print '-------------------' + nr + '--------------------------'
    sData = {'tab':'daily','sect':nr}
    sDay, sWeek, sMonth = sl.getSeries({'tab':'daily','sect':nr})
    ##sTel, tWeek, tMonth = sl.getSeries({'tab':'daily_tel','sect':nr})
    sPali, pWeek, pMonth = sl.getSeries({'tab':'tv_pali','sect':nr})
    hDay, hWeek, hMonth = sl.getSeries({'tab':'daily_hist','sect':nr})
    reload(sl)
    startC = json.load(open(os.environ['LAV_DIR'] + "/train/series_interp.json"))
    x0 = startC[nr]
    #x0 = sl.getStartParam({'tab':'train_s','sect':nr})
    histPali = pd.concat([pWeek.y,hWeek.y],join='outer',axis=1)
    histPali.columns = ['y1','y2']
    histPali['y'] = histPali['y1'] * histPali['y2']
    histPali['y'][np.isnan(histPali.y)] = histPali['y2'][np.isnan(histPali.y)]
    hWeek.y = histPali['y']/histPali['y'].max()
    sDay1 = pd.DataFrame(sDay.head(sDay.shape[0]-nAhead))
    predD = pd.DataFrame(sDay.tail(nAhead)['y'])

    testD, x1 = sl.serArma(sDay1,nAhead,x0,hWeek)
    predD['arma'] = testD.tail(nAhead)['pred'] - predD['y']
    testD, x1 = sl.serHolt(sDay1,nAhead,x0,hWeek)
    predD['holt'] = testD.tail(nAhead)['pred'] - predD['y']
    testD, x1 = sl.serAuto(sDay1,nAhead,x0,hWeek)
    predD['autocor'] = testD.tail(nAhead)['pred'] - predD['y']
    testD, x1 = sl.extSeries(sDay1,nAhead,x0,hWeek)
    predD['lsq'] = testD.tail(nAhead)['pred'] - predD['y']

    predD['week'] = [predD.index[x].isocalendar()[1] for x in range(predD.shape[0])]
    predW = predD.groupby(["week"]).sum()/1000000
    predP = {'arma':"%.3f" % ((predD['arma']**2).sum()/(predD['y']**2).sum())
             ,'holt':"%.3f" % ((predD['holt']**2).sum()/(predD['y']**2).sum())
             ,'autocor':"%.3f" % ((predD['autocor']**2).sum()/(predD['y']**2).sum())
             ,'lsq':"%.3f" % ((predD['lsq']**2).sum()/(predD['y']**2).sum())
             ,'w_arma':"%.3f" % ((predW['arma']**2).sum()/(predW['y']**2).sum())
             ,'w_holt':"%.3f" % ((predW['holt']**2).sum()/(predW['y']**2).sum())
             ,'w_autocor':"%.3f" % ((predW['autocor']**2).sum()/(predW['y']**2).sum())
             ,'w_lsq':"%.3f" % ((predW['lsq']**2).sum()/(predW['y']**2).sum())}

    resS[nr] = predP 
    print (predD['arma']**2).sum()/(predD['y']**2).sum()
    
print json.dumps(sorted(resS.items(),key=lambda x:x[1]),indent=2)
