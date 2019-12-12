import urlparse
from urllib import quote_plus as urlquote
import urllib2
import requests
import json
import re
import time
import MySQLdb
from pandas.io import sql
import sqlalchemy
import os
import pandas as pd
import datetime

print '----------------------api-webtrekk-------------------'
dataQ = ["2017-05-01","2017-05-25"]

dataQ = [(datetime.date.today() - datetime.timedelta(days=1)).strftime("%Y-%m-%d") + ' 00:00:00',(datetime.date.today() - datetime.timedelta(days=1)).strftime("%Y-%m-%d")  + ' 23:59:59']
dataQ = [(datetime.date.today() - datetime.timedelta(days=2)).strftime("%Y-%m-%d"),(datetime.date.today() - datetime.timedelta(days=1)).strftime("%Y-%m-%d")]

headers = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
baseUrl = 'https://report2.webtrekk.de/cgi-bin/wt/JSONRPC.cgi'

sData = {"params": {},"version": "1.1","method": "getConnectionTest"}
resq = requests.post(baseUrl,data=json.dumps(sData))
key_file = os.environ['LAV_DIR'] + '/credenza/webtrekk.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)
resq = requests.post(baseUrl,data=json.dumps(cred))
token = resq.json()['result']

query = {"params": {"token": token,"report_name": "Player","time_start":dataQ[0],"time_stop":dataQ[1],"footerIdentifier":"remove"},"version": "1.1","method": "getReportData"}
resq = requests.post(baseUrl,data=json.dumps(query))
videoD = resq.json()['result']['analyses'][1]['analysisData']

query = {"params": {"token": token,"report_name": "preroll"},"version": "1.1","method": "getReportData"}
resq = requests.post(baseUrl,data=json.dumps(query))
prerollD = resq.json()['result']['analyses'][0]['analysisData']

##-----------------------transform-------------------------------

videoL = []
roll = 0
partner = 0
for d in range(0,len(videoD)):
    if re.search("roll",videoD[d][1]):
        roll = roll + int(videoD[d][2])
    if re.search("embed",videoD[d][1]):
        partner = partner + int(videoD[d][2])

prerollF = pd.DataFrame({"date":[x[0] for x in prerollD],"section":[x[1] for x in prerollD],"imps":[x[2] for x in prerollD],"group":"rest"})
prerollF = prerollF.head(prerollF.shape[0]-2)
prerollF['imps'] = prerollF['imps'].apply(lambda x: pd.to_numeric(x,errors="ignore"))
prerollF['imps'] = pd.to_numeric(prerollF['imps'])
sectL = pd.read_csv(os.environ['LAV_DIR'] + "/raw/inventoryVideoSection.csv")
for i in range(0,len(sectL)):
    idxA = prerollF['section'].str.contains(str(sectL['canale'][i]))
    prerollF.loc[idxA,['group']] = str(sectL['cluster'][i])

prerollF = prerollF[['date','group','imps']]
prerollS = prerollF.groupby(["date","group"]).sum().unstack()

today = str(resq.json()['result']['analyses'][0]['timeStart'])[0:10]
todayD = datetime.datetime.strptime(today,"%Y-%m-%d")
videoL = pd.DataFrame(
    {"date":today,videoD[0][1]:[videoD[0][2]],videoD[1][1]:[videoD[1][2]],videoD[2][1]:[videoD[2][2]],"preroll":[roll],"embed":[partner],"week":todayD.strftime("%y-%W"),"weekD":todayD.weekday()}
##    ,index=[today]
    ,columns=["date",videoD[0][1],videoD[1][1],videoD[2][1],"preroll","embed","week","weekD"])
videoL.index.name = "idx"
videoL = videoL.set_index(['date'])

##----------------------------------load-----------------------------

key_file = os.environ['LAV_DIR'] + '/credenza/intertino.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)

cred = cred['mysql']['intertino']
engine = sqlalchemy.create_engine('mysql://'+cred['user']+':'+cred['pass']+'@'+cred['host']+'/'+cred['db'],echo=False)
conn = engine.connect()
videoL.to_sql('inventory_webtrekk_preroll',conn,if_exists='append',chunksize=100,index_label="date")
prerollS.imps.to_sql('inventory_webtrekk_section',conn,if_exists='append',chunksize=100,index_label="date")
print '---api-webtrekk-te-se-qe-te-ve-be-ne-------------'


