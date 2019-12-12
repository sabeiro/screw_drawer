import os
import sys
import random
import json
import numpy as np
import pandas as pd
import api_blueLib as bk
import threading
from Queue import Queue
import time
import multiprocessing as mp
import re

Url = 'http://services.bluekai.com/Services/WS/SegmentInventory?countries=ALL'
uDom = 'http://services.bluekai.com'
uPath = '/Services/WS/'
uServ = 'audiences'
data = '{}'
method = 'GET'

newUrl = bk.signatureInputBuilder(uDom+uPath+uServ,'GET', None)
audL = json.loads(bk.doRequest(newUrl,'GET', None))
aCamp = []
aud = audL['audiences'][15]

audName = "g-o"
audId = 142110

def singReq(q,audId,audName):
    if any([x in audName for x in ["obsolete","pub","s-d"]]):
        return
    print audName.encode('utf-8')
    newUrl = bk.signatureInputBuilder(uDom+uPath+uServ+'/'+str(audId),'GET', None)
    audComp = json.loads(bk.doRequest(newUrl,'GET', None))
    aCamp.append(json.dumps(audComp['campaigns']))
    data = json.dumps(audComp['segments'],separators=(',', ':'))
    newUrl = bk.signatureInputBuilder(Url,'POST',data)
    resp = json.loads(bk.doRequest(newUrl,'POST',data))
    sCat = ''
    sReach = ''
    for cat in resp['AND'][0]['AND'][0]['OR']:
        sCat += str(cat['AND'][0]['cat']) + ', '
        sReach += str(cat['AND'][0]['reach']) + ', '
    aLine = {'name':audName,'id':audId,'reach':resp['reach'],'camp':json.dumps(audComp['campaigns']),"cat":sCat,"catReach":sReach}
    aReach.append(aLine)
#    q.put(aLine)


concurrent = 20
q = mp.Queue()
q = Queue(concurrent*2)
aReach = []
for aud in audL['audiences']:
#    print aud['id'],aud['name']
    singReq(q,aud['id'],aud['name'])

# thread_pool = []
# for aud in audL['audiences']:
#     # p = mp.Process(target=singReq,args=(q,aud['id'],aud['name']))
#     # p.start()
#     # print(q.get())
#     # p.join()
#     t = threading.Thread(target=singReq,args=(q,aud['id'],aud['name']))
#     t.daemon = True
#     thread_pool.append(t)
#     t.start()

    
# for col in aLine:
#     aLine[col] = data[col].str.decode('iso-8859-1').str.encode('utf-8')

audState = pd.DataFrame(aReach)
print audState.apply(lambda x: pd.lib.infer_dtype(x.values))
audState.name = audState.name.str.encode('utf-8')
audState.to_csv(os.environ['LAV_DIR'] +  "/raw/audReach.csv",encding='utf-8')
#audState.to_csv("../../raw/audReach.csv",encoding='cp1252')
# aList = namedtuple('name', 'id')
# aName = [aList(**k) for k in resp["audiences"]]

