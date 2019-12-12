##https://developer.yahoo.com/brightroll/dsp/api/docs/authentication/
##https://developer.yahoo.com/apps/0TH8345e/

import urllib
import urllib2
import cookielib
import base64
import requests
import json
import csv
import re
import time
import datetime
import numpy as np
import pandas as pd
import os

print '-----------------------api-brightroll--------------------------------'

headers = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
baseUrl = 'https://api.login.yahoo.com/oauth2/'
today = time.strftime("%Y-%m-%d")
dataQ = [(datetime.date.today() - datetime.timedelta(days=1)).strftime("%Y-%m-%d"),(datetime.date.today() - datetime.timedelta(days=1)).strftime("%Y-%m-%d")]

sData = {"params": {},"version": "1.1","method": "getConnectionTest"}
key_file = os.environ['LAV_DIR'] + '/credenza/brightroll.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)

headers = {"Authorization":"Basic "+base64.standard_b64encode(cred['client_id']+":"+cred['client_secret']),"Content-Type":"application/x-www-form-urlencoded"}
# sData = {"grant_type":"authorization_code","redirect_uri":"oob","code":cred['app_code']} # gen refresh token
sData = {"grant_type":"refresh_token","redirect_uri":"oob","refresh_token":cred['refresh_token']} # get access token
resq = requests.post(baseUrl+'get_token',headers=headers,data=sData)
token = resq.json()['access_token']
headers = {"Content-Type":"application/json","X-Auth-Method":"OAUTH","X-Auth-Token":token}
sData = {"reportOption": {
    "timezone": "Europe/Paris"
    ,"currency": 3
    ,"dimensionTypeIds": [4,5]
    ##,"dimensionTypeIds": [5,39]
    ,"metricTypeIds": [1,2,23,44,46]
    #,"metricTypeIds": [1,2]
},
         "intervalTypeId": 1
         ,"dateTypeId": 2
        # ,"startDate": dataQ[0] + "T00:00:00-05:00"
         # ,"endDate": dataQ[1] + "T11:59:59-05:00"
         ,"startDate": "2017-02-01" + "T00:00:00-05:00"
         ,"endDate": "2017-02-20" + "T11:59:59-05:00"
}
baseUrl = "http://api-sched-v3.admanagerplus.yahoo.com/yamplus_api/extreport/"
resq = requests.post(baseUrl,headers=headers, data=json.dumps(sData))
time.sleep(.5)
repId = resq.json()['customerReportId']

print resq.json()['status']
stat = ""
counter = 1
while stat not in ["Success",401]:
    resq = requests.get("http://api-sched-v3.admanagerplus.yahoo.com/yamplus_api/extreport/"+repId,headers=headers)
    time.sleep(2)
    stat = resq.json()['status']
    time.sleep(2)
    print counter
    counter += 1
    if counter > 100:
        break


    
print stat
repLink = resq.json()['url']
repFile = '/var/www/webdav/report_brightroll/' + 'camp' + today + 'Brightroll' + '.csv'
urllib.urlretrieve(repLink,filename=repFile)


resq = requests.get(repLink,headers=headers,verify=False)
content = resq.content.decode('utf-8').strip()
content = resq.content.decode('ascii', 'ignore').decode('ascii')
cr = csv.reader(content.splitlines(), delimiter=',')
campL = []
for i in range(0,cr.line_num):
    campL.append(cr.next())
    print i

for row in cr:
    campL.append(row)

    
cr_list = list(cr)
for row in cr_list:
    campL.append(row)

campDf = pd.DataFrame(campL)
##campDf.to_csv(repFile,encding='utf-8')
##campDf.to_csv("../../raw/audUseBright.csv",encoding='utf-8')
# aList = namedtuple('name', 'id')
#

#print 'curl "https://api.login.yahoo.com/oauth2/get_token" -X POST -H "Content-Type: application/x-www-form-urlencoded" -H "Authorization: Basic '+base64.standard_b64encode(cred['client_id']+":"+cred['client_secret'])+'" -d "grant_type=authorization_code&redirect_uri=oob&code='+cred['app_code']+'"'

print '---------api-brightroll-te-se-qe-te-ve-be-te-ne--------------'
