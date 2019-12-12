##https://developers.google.com/doubleclick-publishers/docs/reference/v201705/ReportService.Dimension

import sys
import api_dotLib as dot
import numpy as np
import pandas as pd
##import clipboard
import re
import StringIO
import time
import datetime as dt
from datetime import datetime
from datetime import timedelta

import json
from urllib import quote_plus as urlquote
import os
import api_dfpLib as dfp

##-----------------------read-from-dot---------------------------
print '-------------------------------spot---------------------------------'

token = dot.getToken()
dataQ = ["2017-07-07","2017-07-08"]
trentaGG = ["31","28","31","30","31","30","31","31","30","31","30","31"]
prevM = int(dt.date.today().strftime("%m")) - 1
dataQ = ["2017-" + "%02d" % (prevM) + "-01","2017-" + "%02d" % (prevM) + "-" + trentaGG[prevM-1]]
headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
##tappi
query = {"token":token,
    "request":{
        "reportId":"MD",
        "fields":[{"id":"Date","sortd":"desc","visible":True,"sortp":1,"filters":[[{"op":">=","v": [dataQ[0]]}],[{"op":"<=","v": [dataQ[1]]}]]}
        ,{"id":"Size","visible": False,"sortp":1,"filters":[[{"op":"=","v": ["SPOT"]}]]}
        ,{"id":"Publisher","sort":"asc","sortp":2}
        ,{"id":"Site","sort":"asc","sortp":3}
        ,{"id":"Channel","sort":"asc","sortp":4}
        ,{"id":"Section","sort":"asc","sortp":5}
        ,{"id":"Imps"}
        ]
    }
}
#headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
rep = dot.waitRep(token,query,headers)
spotD = pd.DataFrame(dot.formRep(rep.content))
spotD.rename(columns={0:"data",1:"publisher",2:"site",3:"section",4:"subsection",5:"imps"},inplace=True)
spotD['size'] = 'preroll'
spotD['size'][spotD['subsection'].str.contains("PUSH")] = 'pushdown'
spotD['size'][spotD['subsection'].str.contains("INREAD")] = 'inread'
spotD['size'][spotD['subsection'].str.contains("INPAGE")] = 'inpage'
spotD['imps'] = pd.to_numeric(spotD['imps'])

spotI = spotD.set_index(["publisher","site","section","size"])
spotS = spotD.groupby(["size"]).imps.sum()
spotS0 = spotD.groupby(["publisher","size"]).imps.sum().unstack()
spotS1 = spotD.groupby(["publisher","site","size"]).imps.sum().unstack()
spotS2 = spotD.groupby(["publisher","site","section","size"]).imps.sum().unstack()
spotS0.fillna(0,inplace=True)
spotS1.fillna(0,inplace=True)
spotS2.fillna(0,inplace=True)
i0 = spotI.index.get_level_values('publisher').unique()[0]
i1 = spotI.index.get_level_values('site').unique()[0]
i2 = spotI.index.get_level_values('section').unique()[0]
prezzD0 = dict()
for i0 in spotI.index.get_level_values('publisher').unique():
    i0Filt = spotI.index.get_level_values('publisher') == i0
    prezzD1 = dict()
    for i1 in spotI[i0Filt].index.get_level_values('site').unique():
        i1Filt = spotI.index.get_level_values('site') == i1
        prezzD2 = dict()
        for i2 in spotI[i1Filt].index.get_level_values('section').unique():
            i2Filt = (spotS2.index.get_level_values('site') == i1) & (spotS2.index.get_level_values('section') == i2)
            valL = [x for x in spotS2[i2Filt].values[0]]
            valL.insert(0,sum(valL))
            prezzD2[i2] = {"label_short":i2,"label_long":i2,"values":valL}
        i1Filt = (spotS1.index.get_level_values('site') == i1)
        valL = [x for x in spotS1[i1Filt].values[0]]
        valL.insert(0,sum(valL))
        chL = [prezzD2[x] for x in prezzD2]
        chOrder = [i[0] for i in sorted(enumerate([x['values'][0] for x in chL]),key=lambda x:x[1],reverse=True)]
        chL = [chL[x] for x in chOrder]
        prezzD1[i1] = {"label_short":i1,"label_long":i1,"children":chL,"values":valL}
    i0Filt = spotS0.index.get_level_values('publisher') == i0
    valL = [x for x in spotS0[i0Filt].values[0]]
    valL.insert(0,sum(valL))
    chL = [prezzD1[x] for x in prezzD1]
    chOrder = [i[0] for i in sorted(enumerate([x['values'][0] for x in chL]),key=lambda x:x[1],reverse=True)]
    chL = [chL[x] for x in chOrder]
    prezzD0[i0] = {"label_short":i0,"label_long":i0,"children":chL,"values":valL}
valL = [x for x in spotS.values]
valL.insert(0,sum(valL))
chL = [prezzD0[x] for x in prezzD0]
chOrder = [i[0] for i in sorted(enumerate([x['values'][0] for x in chL]),key=lambda x:x[1],reverse=True)]
chL = [chL[x] for x in chOrder]
menuL = [x for x in spotI.index.get_level_values('size').unique()]
prezzD = {"title":"prezzario","depth":2,"label_short":"spot 17-%02d"%prevM,"label_long":"spot 17-%02d"%prevM,"children":chL,"values":valL,"menu":menuL}

with open(os.environ['LAV_DIR']+"/intertino/data/heatSpot17-%02d.json"%prevM,'w') as outfile:
    json.dump(prezzD, outfile,indent=2)
spotS2.to_csv(os.environ['LAV_DIR']+"/intertino/data/heatSpot17-%02d.csv"%prevM)

print '-------------------------------display---------------------------------'
            
dAuth = dfp.dfpAuth()
values = [{'key':'parent_ad_unit_id','value':{'xsi_type':'NumberValue','value':dAuth.root_ad_unit_id}}]
filter_statement = {'query': 'WHERE PARENT_AD_UNIT_ID = :parent_ad_unit_id','values': values}
dataQ = [datetime.now().date() - timedelta(days=1),datetime.now().date()]
report_job = {
    'reportQuery': {
        'dimensions': ['AD_UNIT_NAME','CREATIVE_SIZE','DEVICE_CATEGORY_NAME']##cretive_size device_category
#        ,'adUnitView': 'HIERARCHICAL'
        ,'columns': ['AD_SERVER_IMPRESSIONS','AD_SERVER_CLICKS']
        ##,'dateRangeType': 'CUSTOM_DATE','startDate': dataQ[0],'endDate': dataQ[1]
        ,'dateRangeType': 'LAST_MONTH'
##        ,'statement': filter_statement
    }}
repF = dAuth.runRep(report_job)
dispD = pd.DataFrame(repF)
dispD = dispD[dispD.index != 0]
dispD.columns = ["pos","size_s","device","id","dev_id","imps","click"]
dispD['imps'] = pd.to_numeric(dispD['imps'])
dispD['site'] = [x[-1] for x in dispD.pos.str.split("_",1)]
dispD['publisher'] = [x[0] for x in dispD.pos.str.split("_",1)]
dispD['publisher'][~dispD['pos'].str.contains("_")] = 'banzai'
dispD['publisher'][dispD['publisher'] == "o2o"] = 'banzai'
dispD = dispD[dispD["publisher"]!="test"]
dispD = dispD[dispD["publisher"]!="z"]
dispD['device'][dispD['device'].str.contains(r"[pP]hone")] = 'mobile'
dispD['device'][dispD['device'].str.contains(r"Tablet")] = 'mobile'
dispD['size'] = 'altro'
dispD.loc[dispD['size_s'] == "Out-of-page","size"] = 'overlayer'
dispD.loc[dispD['size_s'] == "400 x 300v","size"] = 'spot'
dispD.loc[dispD['size_s'] == "100 x 100","size"]  = 'skin'
dispD.loc[dispD['size_s'] == "300 x 250","size"]  = 'box'
dispD.loc[dispD['size_s'] == "300 x 600","size"]  = 'halfpage'
dispD.loc[dispD['size_s'] == "728 x 90" ,"size"]  = 'leaderboard'
dispD.loc[dispD['size_s'] == "980 x 250","size"]  = 'masthead'
dispD.loc[dispD['size_s'] == "970 x 250","size"]  = 'masthead'
dispD.loc[dispD['size_s'] == "320 x 50" ,"size"]  = 'minibox'
dispD['size'] = dispD['size'] + "-" + dispD['device']
dispD = dispD.loc[:,["size","publisher","site","imps"]]

dispI = dispD.set_index(["publisher","site","size"])
dispS = dispD.groupby(["size"]).imps.sum()
dispS0 = dispD.groupby(["publisher","size"]).imps.sum().unstack()
dispS1 = dispD.groupby(["publisher","site","size"]).imps.sum().unstack()
dispS0.fillna(0,inplace=True)
dispS1.fillna(0,inplace=True)
i0 = dispI.index.get_level_values('publisher').unique()[0]
i1 = dispI.index.get_level_values('site').unique()[0]
prezzD0 = dict()
for i0 in dispI.index.get_level_values('publisher').unique():
    i0Filt = dispI.index.get_level_values('publisher') == i0
    prezzD1 = dict()
    for i1 in dispI[i0Filt].index.get_level_values('site').unique():
        i1Filt = (dispS1.index.get_level_values('site') == i1)
        valL = [x for x in dispS1[i1Filt].values[0]]
        valL.insert(0,sum(valL))
        prezzD1[i1] = {"label_short":i1,"label_long":i1,"values":valL}
    i0Filt = dispS0.index.get_level_values('publisher') == i0
    valL = [x for x in dispS0[i0Filt].values[0]]
    valL.insert(0,sum(valL))
    chL = [prezzD1[x] for x in prezzD1]
    chOrder = [i[0] for i in sorted(enumerate([x['values'][0] for x in chL]),key=lambda x:x[1],reverse=True)]
    chL = [chL[x] for x in chOrder]
    prezzD0[i0] = {"label_short":i0,"label_long":i0,"children":chL,"values":valL}
valL = [x for x in dispS.values]
valL.insert(0,sum(valL))
chL = [prezzD0[x] for x in prezzD0]
chOrder = [i[0] for i in sorted(enumerate([x['values'][0] for x in chL]),key=lambda x:x[1],reverse=True)]
chL = [chL[x] for x in chOrder]
menuL = [x for x in dispI.index.get_level_values('size').unique()]
prezzD = {"title":"prezzario","depth":2,"label_short":"display 17-%02d"%prevM,"label_long":"display 17-%02d"%prevM,"children":chL,"values":valL,"menu":menuL}

with open(os.environ['LAV_DIR']+"/intertino/data/heatDisp17-%02d.json"%prevM,'w') as outfile:
    json.dump(prezzD, outfile,indent=2)
dispS1.to_csv(os.environ['LAV_DIR']+"/intertino/data/heatDisp17-%02d.csv"%prevM)


##re.search(r'(\A.*)\.\.\..+',url,re.DOTALL|re.IGNORECASE).group(1)

print '-------etl-sizeImps-te-se-qe-te-ve-be-ne-------'

