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

print '-----------------------series-prev--------------------------------'

todayD = datetime.datetime.today()
todayD = todayD.replace(hour=0,minute=0,second=0,microsecond=0)
yesterdayD = todayD - datetime.timedelta(days=1)

startC = {}
with open(os.environ['LAV_DIR']+"/train/series_interp.json") as f:
    startC = json.load(f)

predD = pd.DataFrame()
predW = pd.DataFrame()
endC = {}
resS = []
resqW = pd.DataFrame()
nAhead = 14 + datetime.datetime.today().weekday()
nr = startC.keys()[9]
for nr in sorted(startC.keys(),key=lambda x:x[0]):
    print '-------------------' + nr + '--------------------------'
    sData = {'tab':'daily','sect':nr}
    sData = {'tab':'daily_hist','sect':nr}
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
    hWeek.y =  ( (histPali['y']-histPali['y'].min())/(histPali['y'].max()-histPali['y'].min()) + 1.)*x0['hist_adj']
    if(x0['model']=='arma'):
        testD, x1 = sl.serArma(sDay,nAhead,x0,hWeek)
    elif(x0['model']=='holt'):
        testD, x1 = sl.serHolt(sDay,nAhead,x0,hWeek)
    elif(x0['model']=='autocor'):
        testD, x1 = sl.serAuto(sDay,nAhead,x0,hWeek)
    else:##lsq
        testD, x1 = sl.serLsq(sDay,nAhead,x0,hWeek)

    print x1
    if False:
        sl.plotSer(sDay,testD,nr + ' ' + x1['model'])
    
    endC[nr] = x1
    predD[nr] = testD['pred']


    
with open(os.environ['LAV_DIR']+"/train/series_interp.json",'w') as outfile:
    json.dump(endC, outfile,indent=2)

#print json.dumps(sorted(startC.keys(),key=lambda x:x[0]),indent=2,separators=(',', ':'))


print [ "%.2f" % x for x in resS]

predD1 = predD[predD.index>yesterdayD]
predD1.fillna(0,inplace=True)
predD1.columns = sorted(startC.keys(),key=lambda x:x[0])
predD2 = predD1.apply(lambda x:x*1000000).astype(int)

predD2['week'] = [predD2.index[x].isocalendar()[1] for x in range(predD2.shape[0])]
predDW = predD2.groupby(["week"]).sum()/1000000
predDW['count'] = predD2.groupby(["week"]).size()
predDW = predDW.query("count == 7")
base = datetime.datetime.strptime("2017-01-01","%Y-%m-%d")
matchWD = pd.DataFrame(index=[base + datetime.timedelta(days=x) for x in range(0,365)])
matchWD['week'] = [matchWD.index[x].isocalendar()[1] for x in range(matchWD.shape[0])]
matchWD = matchWD[matchWD.index.weekday==3]
matchDW = pd.DataFrame({'date':matchWD.index},index=matchWD.week)
predDW =  pd.merge(predDW,matchDW,how="left",left_index=True,right_index=True)
predDW['tot'] = predDW.sum(axis=1)
predW['tot'] = predW.sum(axis=1)

conn = dbs.open_conn()
predD2.to_sql('inventory_prediction_daily',conn,if_exists='replace',chunksize=100,index_label="date")
predDW.to_sql('inventory_prediction_weekly',conn,if_exists='replace',chunksize=100)
#cursor = conn.cursor()
#cursor.execute('create table train_series')
#resquare.to_sql('train_series',conn,if_exists='replace',chunksize=100)
conn.close()

print '--------series-prev-te-se-qe-te-ve-be-ne-------'
