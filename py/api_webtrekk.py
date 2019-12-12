import urlparse
import urllib
import urllib2
import cookielib
import hashlib
import hmac
import base64
import requests
import json
import re
import time
import datetime
import pandas as pd
import os

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
if False:
    query = {"params": {"token":token},"version": "1.1","method": "getAnalysisObjectsAndMetricsList"}##metriche
    resq = requests.post(baseUrl,data=json.dumps(query))
    #for i in resq.json()['result']['metrics']:
    for i in resq.json()['result']['analysisObjects']:
        #    if re.search("Media",i):
        print i
    query = {"params": {"token":token},"version": "1.1","method": "getCustomReportsList"}##reresq = requests.post(baseUrl,data=json.dumps(query))
    query = {"params": {"token":token},"version": "1.1","method": "getDynamicTimeIntervalList"}##time interval
    resq = requests.post(baseUrl,data=json.dumps(query))
    print resq.json()


stTime = datetime.date(2017,03,01)
enTime = stTime + datetime.timedelta(0)
campL = []
for i in range(27,91):
    print i
    if i%10==0:
        resq = requests.post(baseUrl,data=json.dumps(cred))
        token = resq.json()['result']
    enTime = stTime + datetime.timedelta(i)
    query = {"params": {"token":token
                        ,"analysisConfig":{
                            "hideFooters": 1
                            #,"analysisFilter":{"filterRules": [{"objectTitle":"Pages","comparator":"=","filter":"*misya*","scope":"visit"},{"link":"and","objectTitle":"Browser","comparator":"!=","filter": "*Chrome*"}]}
                            ,"metrics": [
                                {"sortOrder": "desc","title": "Page Impressions"}
                            ,{"title": "Visits"}#,"metricFilter": {"filterRules": [{"objectTitle": "Pages","comparator": "=","filter": "*index*"}]}}
                                ,{"title": "Browsers, Unique"}
                        ]
                            ,"rowLimit": 1000000
                            ,"analysisObjects": [
                                ##{"sortOrder": "asc","title": "Days"}
                                {"sortOrder": "asc","title": "Livello1 - Editore"}
                            ]
                            ,"startTime":stTime.strftime("%Y-%m-%d") + " 00:00:00"
                            ,"stopTime":enTime.strftime("%Y-%m-%d") + " 23:59:59"
                        }
    }
             ,"version": "1.1","method": "getAnalysisData"
    }
    resq = requests.post(baseUrl,data=json.dumps(query))
    for row in resq.json()['result']['analysisData']:
        ##row.append(enTime.strftime("%Y-%m-%d"))
        row.append(i)
        campL.append(row)
        
print 'done'
campD = pd.DataFrame(campL)
campD.columns = ["editore","imps","visit","unique","span"]
campD.to_csv(os.environ['LAV_DIR']+"raw/uniqueProgression1.csv",encoding='utf-8',index=False)
        




query = {"params": {"token": token,"report_name": "Player"},"version": "1.1","method": "getReportData"}
resq = requests.post(baseUrl,data=json.dumps(query))
print resq.json()

query = {"params": {"token":token,"startRow": 1,"endRow": 1000,"type": "content_categories"},"version": "1.1","method": "exportData"}
resq = requests.post(baseUrl,data=json.dumps(query))
print resq.json()
