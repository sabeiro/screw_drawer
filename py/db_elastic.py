import sys
import numpy as np
import pandas as pd
import re
import requests
import time
import datetime
import json
from urllib import quote_plus as urlquote
import os
import requests
import string

##create index
headers = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
baseUrl = 'http://localhost:9200/'
sData = {"pretty":""}
indexN = 'dotandsales-17'
##create
##requests.put(baseUrl+indexN+'?pretty&pretty',headers=headers,data={})
##delete
##requests.delete(baseUrl+indexN+'/external/'+str(i)+"?pretty",headers=headers)
requests.delete(baseUrl+indexN+"?pretty",headers=headers)
##list
resq = requests.get(baseUrl+'_cat/indices?v&pretty',headers=headers)
##set geo points
# sData = {"mappings": {"_default_": {"properties": {"geo": {"type": "geo_point"}}}}}
# requests.put(baseUrl+indexN+'?pretty&pretty',headers={},data=json.dumps(sData))

# notA16 = pd.read_csv(os.environ['LAV_DIR'] + "raw/storicoERP2016.csv")
# notA17 = pd.read_csv(os.environ['LAV_DIR'] + "raw/storicoERP2017.csv")
# notA = notA16.append(notA17)
notA = pd.read_csv(os.environ['LAV_DIR'] + "raw/storicoERP2017.csv")
notA['Data Prenotazione'].fillna("2017-01-01",inplace=True)
notA.fillna("",inplace=True)
notA.Cliente =  notA.Cliente.str.lower()
notA.Cliente = notA.Cliente.apply(lambda x:''.join([i for i in x if i not in string.punctuation]))
notA.Cliente = notA.Cliente.apply(lambda x: x.decode("ascii","ignore"))
notA.Formato =  notA.Formato.str.lower()
notA.Formato = notA.Formato.apply(lambda x:''.join([i for i in x if i not in string.punctuation]))
notA.Formato = notA.Formato.apply(lambda x: x.decode("ascii","ignore"))
notA.Pacchetto = notA.Pacchetto.str.lower()
notA.Pacchetto = notA.Pacchetto.apply(lambda x:''.join([i for i in x if i not in string.punctuation]))
notA.Pacchetto = notA.Pacchetto.apply(lambda x: x.decode("ascii","ignore"))
notA.Pacchetto = notA.Pacchetto.apply(lambda x: x[6:] )

sucS = ""
for i in range(0,len(notA)):
    idS = {"index":{"_index":notA.loc[i,'Data Prenotazione'],"_type":"log"}}
    timest = str(notA.loc[i]['Data Prenotazione']) + "T00:00:00Z" 
    tS = "".join(timest)
    sData = {"@timestamp":tS,"client":notA.loc[i]['Cliente'],"pack":notA.loc[i]['Pacchetto'],"order":notA.loc[i]['Numero Contratto'],"gratis":notA.loc[i]['Quantita Gratis'],"n":notA.loc[i]['Quantita Ordine'],'size':notA.loc[i]['Formato'],'rev':notA.loc[i]['Valore Netto']}
    resq = requests.post(baseUrl+indexN+'/external/'+str(i)+"?pretty",headers=headers,data=json.dumps(sData))
    if resq.status_code >= 400:
        print resq.json()
    sucS += " " + str(resq.status_code) #+ resq.text
    if i%20 == 0:
        print sucS
        sucS = ""


##    print "curl -XPUT '" + baseUrl + indexN + '/external/' + i + "?pretty&pretty'" + " -H 'Content-Type: application/json' -d '" + json.dumps(sData) + "'"




