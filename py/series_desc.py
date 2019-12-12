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


print '-----------------------series-desc--------------------------------'

todayD = datetime.datetime.today()
todayD = todayD.replace(hour=0,minute=0,second=0,microsecond=0)
yesterdayD = todayD - datetime.timedelta(days=1)

startC = {}
with open(os.environ['LAV_DIR']+"/train/series_interp.json") as f:
    startC = json.load(f)

webH = pd.DataFrame()
webW = pd.DataFrame()
telH = pd.DataFrame()
nL = sorted(startC.keys(),key=lambda x:x[0])
nL.remove("rest")
nr = startC.keys()[1]
for nr in nL:
    print '-------------------' + nr + '--------------------------'
    sData = {'tab':'daily','sect':nr}
    sDay, sWeek, sMonth = sl.getSeries({'tab':'daily','sect':nr})
    sTel, tWeek, tMonth = sl.getSeries({'tab':'daily_tel','sect':nr})
    sPali, pWeek, pMonth = sl.getSeries({'tab':'tv_pali','sect':nr})
    hDay, hWeek, hMonth = sl.getSeries({'tab':'daily_hist','sect':nr})
    sAll =  pd.merge(sDay['y'].to_frame(),sTel['y'].to_frame(),how="inner",left_index=True, right_index=True)
    #sAll = pd.merge(sAll,sPali['y'].to_frame(),how="inner",left_index=True, right_index=True)
    sAll.columns = ['web','tel']#,'pali']
    sAll['web'] = sAll['web']/sAll['web'].sum()
    sAll['tel'] = sAll['tel']/sAll['tel'].sum()
    ##sAll['pali'] = sAll['pali']/sAll['pali'].sum()
    webH[nr] = sDay['y']/sDay['y'].sum()
    telH[nr] = sTel['y']/sTel['y'].sum()
    webW[nr] = hWeek['y']/hWeek['y'].sum()


telH = telH[telH.sum(axis=1) > 0]
webH = webH[webH.sum(axis=1) > 0]
webW = webW[webW.sum(axis=1) > 0]

autM = sl.autCorM(webH)
pautM = sl.pautCorM(webH)
xcorM = sl.xcorM(webH,telH)

reload(sl)
decM = sl.decayM(autM)
normM = sl.gaussM(xcorM)
lagL = abs((normM.loc[0] - xcorM.shape[0]/2)%7)
statP = pd.concat([webH.describe(),telH.describe(),decM,normM])


plt.plot(xcorM)
plt.show()

corTot = (webH.corr() + telH.corr() + xcorM.corr() + autM.corr() + pautM.corr() + statP.corr())/6
corTot = (webH.corr()*telH.corr()*xcorM.corr()*autM.corr()*pautM.corr()*statP.corr())
# for i in range(corTot.columns.size):
#     corTot[corTot.columns[i]][i] = 0
plt.imshow(corTot)
plt.colorbar()
plt.show()             

plt.pcolor(corTot)
plt.colorbar()
plt.show()             

plt.plot(telH['amici'])
plt.plot(webH['amici'])
plt.show()

plotD = {"type":"line","x":"lag","y":"amplitude","tit":"auto correlation","leg_line":"channel","leg_area":"channel","fig_name":"intertino/fig/serChAut.jpg","smooth":True,"point":False,"log":False,"leg_pos":"down","melt":True,"seq_x":True,"order":"var"}

plotD['type'] = "cor"
plotD['fig_name'] = "intertino/fig/serCor.jpg"
with open(os.environ['LAV_DIR']+"/tmp/tmp.json",'w') as outfile:
    json.dump(plotD,outfile,indent=2)
corTot.to_csv(os.environ['LAV_DIR']+"/tmp/tmp.csv")


plotD['type'] = "bar"
# plotD['smooth'] = False
# plotD['seq_x'] = False
# plotD['melt'] = False
plotD['fig_name'] = "intertino/fig/serLag.jpg"
plotD['x'],plotD['y'],plotD['tit'] = "channel","lag (d)","tv/web lag time"
with open(os.environ['LAV_DIR']+"/tmp/tmp.json",'w') as outfile:
    json.dump(plotD,outfile,indent=2)
lagL.to_csv(os.environ['LAV_DIR']+"/tmp/tmp.csv")


plotD['type'] = "line"
plotD['smooth'] = True
plotD['fig_name'] = "intertino/fig/serChAut.jpg"
plotD['x'],plotD['y'],plotD['tit'] = "lag","amplitude","auto correlation"
with open(os.environ['LAV_DIR']+"/tmp/tmp.json",'w') as outfile:
    json.dump(plotD,outfile,indent=2)
autM.to_csv(os.environ['LAV_DIR']+"/tmp/tmp.csv")

plotD['x'],plotD['y'],plotD['tit'] = "lag","amplitude","partial auto correlation"
plotD['fig_name'] = "intertino/fig/serChPaut.jpg"
with open(os.environ['LAV_DIR']+"/tmp/tmp.json",'w') as outfile:
    json.dump(plotD,outfile,indent=2)
pautM.to_csv(os.environ['LAV_DIR']+"/tmp/tmp.csv")

plotD['x'],plotD['y'],plotD['tit'] = "lag","amplitude","cross correlation"
plotD['fig_name'] = "intertino/fig/serXcross2.jpg"
with open(os.environ['LAV_DIR']+"/tmp/tmp.json",'w') as outfile:
    json.dump(plotD,outfile,indent=2)
#xcorM.to_csv(os.environ['LAV_DIR']+"/tmp/tmp.csv")
normM.to_csv(os.environ['LAV_DIR']+"/tmp/tmp.csv")

plotD['x'],plotD['y'],plotD['tit'] = "day","amplitude","signal history"
plotD['fig_name'] = "intertino/fig/serCross.jpg"
with open(os.environ['LAV_DIR']+"/tmp/tmp.json",'w') as outfile:
    json.dump(plotD,outfile,indent=2)
sAll.to_csv(os.environ['LAV_DIR']+"/tmp/tmp.csv")


plotD['type'] = "stack_line"
plotD['smooth'] = False
plotD['fig_name'] = "intertino/fig/serWeb.jpg"
plotD['x'],plotD['y'],plotD['tit'] = "day","normalized view","series history"
with open(os.environ['LAV_DIR']+"/tmp/tmp.json",'w') as outfile:
    json.dump(plotD,outfile,indent=2)
webH.to_csv(os.environ['LAV_DIR']+"/tmp/tmp.csv")

plotD['fig_name'] = "intertino/fig/serTel.jpg"
with open(os.environ['LAV_DIR']+"/tmp/tmp.json",'w') as outfile:
    json.dump(plotD,outfile,indent=2)
telH.to_csv(os.environ['LAV_DIR']+"/tmp/tmp.csv")

plotD['fig_name'] = "intertino/fig/serCross.jpg"
with open(os.environ['LAV_DIR']+"/tmp/tmp.json",'w') as outfile:
    json.dump(plotD,outfile,indent=2)
normM.to_csv(os.environ['LAV_DIR']+"/tmp/tmp.csv")




from statsmodels.graphics.api import qqplot
import sklearn.model_selection as crossval
from sklearn import datasets
from sklearn import svm





