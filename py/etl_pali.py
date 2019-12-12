import json
import requests
import os
import sys
import random
import json
import numpy as np
import pandas as pd
import urllib
import urllib2
import cookielib
import urlparse
import datetime

print '------------------------------etl-pali-------------------------'

key_file = os.environ['LAV_DIR'] + "/credenza/medianet.json" 
cred = []
with open(key_file) as f:
    cred = json.load(f)

baseUrl = cred['medianet']

monthL = ['2017' + '%02d/' % x for x in range(1,13)]
monthDur = [31,28,31,30,31,30,31,31,30,31,30,31]
monthU = '201703/'
dayU = '20170330'
chU = '_KA'
chU = '_C5'
sectL = pd.read_csv(os.environ['LAV_DIR'] + "/raw/inventoryVideoSection.csv")
sectD = pd.DataFrame(index = sectL.cluster.unique())
titleL = pd.DataFrame()
paliPrg = pd.DataFrame()
today = datetime.datetime.today()
startM = today.month-1-2
startM = startM-12 if startM<0 else startM
for m in range(startM,12):
    for d in range(0,monthDur[m]):
        print (m,d)
        paliL = []
        isCont = False
        #for ch in ['_C5','_I1','_R4']:
        for ch in ['_C5']:
            dateDir = '2017' + '%02d' % (m+1) + '/2017%02d%02d' % (m+1,d+1) + ch +'.sjson'
            resq = requests.get(baseUrl+dateDir)
            if resq.status_code != 200:
                isCont = True
                break
            pali = resq.json()['events']
            for p in pali:
                paliL.append([p['title'].lower(),p['startTime'],p['endTime'],p['genere'].lower()])
        if isCont:
            break
        adSect = pd.DataFrame({'title':np.array(paliL)[:,0],'time':np.array(paliL)[:,1]})
        adSect['group'] = 'rest'
        for i in range(0,len(sectL)):
            idxA = adSect['title'].str.contains(str(sectL['canale'][i]))
            if(idxA.sum<=0):
                next 
            adSect['group'][idxA] = str(sectL['cluster'][i])
        titleL = titleL.append(adSect)
        adSect = adSect[adSect.group!='rest']
        adSect = adSect.groupby('group').group.size()#.apply(lambda x : sum(x!=''))
        adSect = pd.concat([sectD,adSect],axis=1,join="outer")
        adSect = adSect.transpose()
        adSect.index = ['2017-%02d-%02d' % (m+1,d+1)]
        paliPrg = paliPrg.append(adSect)

        
paliPrg.fillna(0,inplace=True)
paliPrg = paliPrg.apply(lambda x: x/np.max(x)*1000000)
paliPrg.fillna(0,inplace=True)
paliPrg.index = [datetime.datetime.strptime(x,"%Y-%m-%d") for x in paliPrg.index]
paliPrg['rest'] = 0

titleD = titleL.groupby(['title','group']).title.size()
##titleD.to_csv('tmp.csv')

import MySQLdb
from pandas.io import sql
import sqlalchemy

key_file = os.environ['LAV_DIR'] + '/credenza/intertino.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)
cred = cred['mysql']['intertino']
engine = sqlalchemy.create_engine('mysql://'+cred['user']+':'+cred['pass']+'@'+cred['host']+'/'+cred['db'],echo=False)
conn = engine.connect()
paliPrg.to_sql('inventory_tv_pali',conn,if_exists='replace',chunksize=100,index_label="date")
conn.close()



print '---etl-pali-te-se-qe-te-ve-be-ne-------------'
        
