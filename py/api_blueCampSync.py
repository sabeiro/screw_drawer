import os
import sys
import json
import random
import numpy as np
import pandas as pd
import api_blueLib as bk
import datetime
import re

print '----------------read-campaign/audience-status---------------------'
Url = 'http://services.bluekai.com/Services/WS/SegmentInventory?countries=ALL'
uDom = 'http://services.bluekai.com'
uPath = '/Services/WS/'
uServ = 'audiences'
data = '{}'
method = 'GET'
newUrl = bk.signatureInputBuilder(uDom+uPath+uServ,'GET', None)
audL = json.loads(bk.doRequest(newUrl,'GET', None))
audState = pd.DataFrame([x for x in audL['audiences']])
audState.to_csv(os.environ['LAV_DIR'] + "/raw/bkAudStatus.csv",encoding='utf-8')

uServ = 'Campaign'
newUrl = bk.signatureInputBuilder(uDom+uPath+uServ,'GET', None)
campL = json.loads(bk.doRequest(newUrl,'GET', None))
if False:
    print [x['name'] for x in campL['campaigns'][:]]
campT = []
camp = campL['campaigns'][0]
for camp in campL['campaigns']:
    cLine = {'campaignId':camp["campaignId"],'name':camp["name"],'startDate':camp["startDate"],'campaignState':camp["campaignState"],'audienceId':camp["audienceId"],'audienceName':camp["audienceName"],'activated':camp["activated"],'campaignType':camp["campaignType"],'includeTopNodes':camp["includeTopNodes"],'categoryTransferMethod':camp["categoryTransferMethod"],'pixelURL':json.dumps(camp["pixelURLs"]),'privateSellerTargets':camp["privateSellerTargets"],'retargetingSites':camp["retargetingSites"]}
    campT.append(cLine)
audState = pd.DataFrame(campT)
audState.to_csv(os.environ['LAV_DIR'] + "/raw/bkCampStatus.csv",encoding='utf-8')

uServ = "CampaignPixelURL"
newUrl = bk.signatureInputBuilder(uDom+uPath+uServ+'?pixelURLId=222341','GET',None)
pixL = json.loads(bk.doRequest(newUrl,'GET', None))

print '-------------------read-camp-detail-and-list----------------------'
cTime = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S-05:00")
cDate = datetime.datetime.now().strftime("%Y-%m-%d")
endDate = re.sub("2017","2018",cDate)

if False:
    pixUrl = "https://secure-gl.imrworldwide.com/cgi-bin/m"
    campA = pd.read_csv(os.environ['LAV_DIR'] + "/raw/audCampListNie.csv") 
    pcList = list()
    idList = list()
    for idx,i in campA.iterrows():
        pcList.append(pixUrl + '?ca=' + str(i['ca']) + '&cr=' + str(i['cr']) + '&ce=' + str(i['ce']) + '&ci=' + str(i['ci']) + '&am=' + str(i['am']) + '&at=' + str(i['at']) + '&rt=' + str(i['rt']) + '&st=' + str(i['st']) + '&pc=' + str(i['pc']) + "&r=$TIMESTAMP")
        idList.append({"id":i['id'],'name':i['name']})
        ##pcList.append(i['baseUrl'] + '?event_id=' + i['event'] + '&event_type=' + i['type'] + '&aud=' + i['camp'])
    campA['pix'] = pcList
    endDate = "2017-09-30"
    campPre = "n-e "

if True:
    pixUrl = "https://beacon.krxd.net/event.gif"
    pixUrl = 'http://tags.bluekai.com/site/32157'#pubmatic
    campA = pd.read_csv(os.environ['LAV_DIR'] + "/raw/audCampListPub.csv")
    campA['n'] = [str(x) for x in range(0,campA.shape[0])]
    campA['pix'] = campA['pix'] + "?camp=" + campA['n']
    campPre = "sync_pub "
    
pData = {
    "audienceId": 110496
    ,"name": "test-API"
    ,"startDate": cDate,"endDate":endDate
    ,"pacingType": "NO_RESTRICTION"
    ,"pacingGoal": 5000
    ,"bid": 0.1
    ,"order": {"budget": 0,"name": "Example Order"}
    ,"jsonResult": False
    ,"includeTopNodes":False
    ,"fixedPrice": False
    ,"campaignState": "ACTIVE"
    ,"campaignType": "NORMAL"
    ,"pixelURLs": [{"pixelURL": "http://tags.bluekai.com/site/9999?cats=$CATEGORIES"}]
    ,"IncludeTopNodes": False
    ,"categoryTransferMethod": "WIN_ONCE_PER_UU"
}

uServ = '/Services/WS/Campaign'
for idx, camp in campA.iterrows():
    pData['name'] = campPre + camp['name']
    pData['audienceId'] = camp['id']
    pData['pixelURLs'][0]['pixelURL'] = camp['pix']
##    pData['id'] = camp['id']
    newUrl = bk.signatureInputBuilder(uDom+uServ,'POST',json.dumps(pData,separators=(',', ':')))
    campL = json.loads(bk.doRequest(newUrl,'POST',json.dumps(pData,separators=(',', ':'))))
    print newUrl





newUrl = bk.signatureInputBuilder("http://services.bluekai.com/rest/campaign.schema",'GET',None)
pixL = json.loads(bk.doRequest(newUrl,'GET', None))
    
newUrl = bk.signatureInputBuilder("http://services.bluekai.com/rest/pixelUrl.schema",'GET',None)
pixL = json.loads(bk.doRequest(newUrl,'GET', None))


