import api_dotLib as dot
import numpy as np
import pandas as pd
##import clipboard
import re
import StringIO
import time
import datetime
import json
import os

print '-----------------------api-dot-video------------------------------'

token = dot.getToken()
dataQ = ["2017-09-11","2017-09-17"]
dataQ = [(datetime.date.today() - datetime.timedelta(days=7)).strftime("%Y-%m-%d"),(datetime.date.today() - datetime.timedelta(days=1)).strftime("%Y-%m-%d")]

headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
##tappi
query = {"token":token,
    "request":{
        "reportId":"MD",
        "fields":[{"id":"Date","sortd":"desc","sortp":1,"filters":[[{"op":">=","v": [dataQ[0]]}],[{"op":"<=","v": [dataQ[1]]}]]}
        ,{"id":"Size","visible": False,"sortp":2,"filters":[[{"op":"=","v": ["SPOT"]}]]}
##        ,{"id":"Publisher","visible": False,"sortp":3,"filters":[[{"op":"=","v": ["WEBTV"]}]]}
        ,{"id":"FlightDescription","visible": False,"sortp":4,"filters":[[{"op":"CONTAINS","v": ["Tapp"]}]]}
        ,{"id":"Imps"}
        ]
    }
}
#headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
rep = dot.waitRep(token,query,headers)
tappi = dot.formRep(rep.content)
##layers
query = {"token":token,
    "request":{
        "reportId":"MD",
        "fields":[{"id":"Date","sortd":"desc","sortp":1,"filters":[[{"op":">=","v": [dataQ[0]]}],[{"op":"<=","v": [dataQ[1]]}]]}
        ,{"id":"Size","visible": False,"sortp":2,"filters":[[{"op":"=","v": ["SPOT"]}]]}
##        ,{"id":"Publisher","visible": False,"sortp":3,"filters":[[{"op":"=","v": ["WEBTV"]}]]}
        ,{"id":"FlightLayer","visible": True,"sortp":4}
        ,{"id":"AdvertiserType","visible": True,"sortp":4}
        ,{"id":"Imps"}
        ]
    }
}
rep = dot.waitRep(token,query,headers)
layers = dot.formRep(rep.content)
#default
query = {"token":token,
    "request":{
        "reportId":"MD",
        "fields":[{"id":"Date","sortd":"desc","sortp":1,"filters":[[{"op":">=","v": [dataQ[0]]}],[{"op":"<=","v": [dataQ[1]]}]]}
        ,{"id":"Size","visible": False,"sortp":2,"filters":[[{"op":"=","v": ["SPOT"]}]]}
##        ,{"id":"Publisher","visible": False,"sortp":3,"filters":[[{"op":"=","v": ["WEBTV"]}]]}
        ,{"id":"AdvertiserType","sortd":"asc","sortp":4}
        ,{"id":"Imps"}
        ]
    }
}
rep = dot.waitRep(token,query,headers)
adType = dot.formRep(rep.content)
#passback
query = {"token":token,
    "request":{
        "reportId":"MD",
        "fields":[{"id":"Date","sortd":"desc","sortp":1,"filters":[[{"op":">=","v": [dataQ[0]]}],[{"op":"<=","v": [dataQ[1]]}]]}
        ,{"id":"Size","visible": False,"sortp":2,"filters":[[{"op":"=","v": ["SPOT"]}]]}
##        ,{"id":"Publisher","visible": False,"sortp":3,"filters":[[{"op":"=","v": ["WEBTV"]}]]}
        ,{"id":"Site","sortp":3,"visible": False,"filters":[[{"op":"=","v": ["VIDEOEXTRA"]}]]}
        ,{"id":"AdvertiserType","visible": False,"sortp":4,"filters":[[{"op":"=","v": ["Default"]}]]}
        ,{"id":"Imps"}
        ]
    }
}
headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
rep = dot.waitRep(token,query,headers)
adPass = dot.formRep(rep.content)

##[x for x in adType if x[1] == "Paganti"][0]

#section
query = {"token":token,
    "request":{
        "reportId":"MD",
        "fields":[{"id":"Date","sortd":"desc","sortp":1,"filters":[[{"op":">=","v": [dataQ[0]]}],[{"op":"<=","v": [dataQ[1]]}]]}
        ,{"id":"Size","visible": False,"sortp":2,"filters":[[{"op":"=","v": ["SPOT"]}]]}
##        ,{"id":"Publisher","visible": False,"sortp":3,"filters":[[{"op":"=","v": ["WEBTV"]}]]}
        ,{"id":"Section","sort":"asc","sortp":3}
        ,{"id":"Imps"}
        ]
    }
}
headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
rep = dot.waitRep(token,query,headers)
adSect =  pd.DataFrame(dot.formRep(rep.content))
adSect.rename(columns={0:"data",1:"section",2:"imps"},inplace=True)

#layer
query = {"token":token,
    "request":{
        "reportId":"MD",
        "fields":[{"id":"Date","sortd":"desc","sortp":1,"filters":[[{"op":">=","v": [dataQ[0]]}],[{"op":"<=","v": [dataQ[1]]}]]}
        ,{"id":"Size","visible": False,"sortp":2,"filters":[[{"op":"=","v": ["SPOT"]}]]}
##        ,{"id":"Publisher","visible": False,"sortp":3,"filters":[[{"op":"=","v": ["WEBTV"]}]]}
        ,{"id":"FlightLayer","sort":"asc","sortp":3}
        ,{"id":"AdvertiserType","sort":"asc","sortp":3}
        ,{"id":"Imps"}
        ]
    }
}
headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
rep = dot.waitRep(token,query,headers)
adLayer =  pd.DataFrame(dot.formRep(rep.content))
adLayer.rename(columns={0:"data",1:"layer",2:"type",3:"imps"},inplace=True)
adLayer['imps'] = adLayer.imps.apply(lambda x: float(x))

# buff = StringIO.StringIO()
# adWeek.to_csv(buff,header=False, index=False)
# buff.seek(0)
# output = buff.getvalue()
# buff.close()
# clipboard.copy(output)
# sectImps[0:20].to_csv(buff,header=False)#, index=False)
# buff.seek(0)
# output = buff.getvalue()
# buff.close()
# clipboard.copy(output)

#channel
query = {"token":token,
    "request":{
        "reportId":"MD",
        "fields":[{"id":"Date","sortd":"desc","sortp":1,"filters":[[{"op":">=","v": [dataQ[0]]}],[{"op":"<=","v": [dataQ[1]]}]]}
        ,{"id":"Size","visible": False,"sortp":2,"filters":[[{"op":"=","v": ["SPOT"]}]]}
        ,{"id":"Publisher","visible": False,"sortp":3,"filters":[[{"op":"=","v": ["WEBTV"]}]]}
                  ##,{"id":"Site","sortp":3,"visible": False,"filters":[[{"op":"=","v": ["LIVE"]}]]}
        ,{"id":"Site","sortp":3,"visible": True}
        ,{"id":"Imps"}
        ]
    }
}
headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
rep = dot.waitRep(token,query,headers)
adLive = pd.DataFrame(dot.formRep(rep.content))
adLive[2] = pd.to_numeric(adLive[2])

weekD = ("Sunday","Saturday","Friday","Thursday","Wednesday","Tuesday","Monday")
videoL = []
for d in range(0,len(tappi)):
    autoP = int(adType[d*3+0][2])
    default = int(adType[d*3+1][2]) - int(adPass[d][1])
    paid = int(adType[d*3+2][2])
    tapp = int(tappi[d][1])
    dLine = (tappi[d][0],weekD[d],paid,default,autoP,tapp,default+autoP+tapp,paid+default+autoP+tapp,tappi[len(tappi)-1][0])
    videoL.append(dLine)

videoD = pd.DataFrame(videoL)
videoD.rename(columns={0:"data",1:"weekD",2:"Paganti",3:"Default",4:"Autopromo",5:"Tappi",6:"Invenduto",7:"Totale inventory",8:"week"},inplace=True)
videoDW = videoD.groupby(["week"]).sum()

adSect['group'] = 'rest'
adSect['imps'] = adSect['imps'].apply(lambda x: pd.to_numeric(x,errors="ignore"))
adSect['imps'] = pd.to_numeric(adSect['imps'])
sectL = pd.read_csv(os.environ['LAV_DIR'] + "/raw/inventoryVideoSection.csv")
for i in range(0,len(sectL)):
    idxA = adSect['section'].str.contains(str(sectL['canale'][i]))
    adSect['group'][idxA] = str(sectL['cluster'][i])

pushNr = adSect['imps'][adSect['section'].str.contains("PUSH")].sum()
inreadNr = adSect['imps'][adSect['section'].str.contains("INREAD")].sum()
inpageNr = adSect['imps'][adSect['section'].str.contains("INPAGE")].sum()
adWeek = adSect.groupby(["group"]).sum()
sectImps = adSect.groupby(["section"]).sum()
sectImps = sectImps.sort_values('imps',ascending=False)
setId = (sectImps.index.str.contains("PUSH")) | (sectImps.index.str.contains("INREAD")) | (sectImps.index.str.contains("INPAGE"))
sectImps = sectImps[~setId]

layersW = pd.DataFrame(layers)
layersW.columns = ['date','layer','type','imps']
layersW['imps'] = layersW['imps'].apply(lambda x: pd.to_numeric(x,errors="ignore"))
layersW['imps'] = pd.to_numeric(layersW['imps'])
layersW['ratio'] = layersW['imps']/layersW['imps'].sum()*100
idL = [x != "3"  for x in layersW.layer]##inread player block
pixInread = layersW[map(lambda x: not x,idL)]['imps'].sum()
layersW = layersW[idL]
layersWT =  layersW.groupby(['type']).sum()
layersWT['ratio'] = layersWT['imps']/layersWT['imps'].sum()*100
layersW =  layersW.groupby(['layer','type']).sum()
layersW['ratio'] = layersW['imps']/layersW['imps'].sum()*100
##layersW['perc'] = layersW['imps']/layersW['imps'].sum()*100

repTxt = dot.wrMatrix(videoD)
repTxt += dot.wrBuffer(videoDW)
repTxt += 'perc invenduto' + str(videoDW['Invenduto']/videoDW['Totale inventory']) + "\n"
repTxt += 'live: ' + str(adLive.groupby([1]).sum()) + "\n"
repTxt += 'altri editori: ' + str(videoD['Totale inventory'].sum() - adLive[2].sum() - inreadNr - pushNr) + "\n"
repTxt += 'push: ' + str(pushNr) + ' inpage: ' + str(inreadNr) + ' inread: ' + str(inpageNr)
#repTxt += dot.wrBuffer(adWeek.sort_values('imps',ascending=False))
#repTxt += adLive[1]
repTxt += dot.wrBuffer(sectImps[0:6])
repTxt += 'top 5 quote ' + dot.wrBuffer(sectImps[0:6].sum()/sectImps.sum()*100.) + '%'
repTxt += 'ratio section: ' + str(sectImps.head(5)['imps'].sum()*100/sectImps['imps'].sum()) + '\n'

repTxt += dot.wrBuffer(layersWT)
repTxt += dot.wrBuffer(layersW)

repFile = '/var/www/webdav/report_dot/' + 'camp' + dataQ[0] + 'Dot' + '.txt'
f = open(repFile,'w')
f.write(repTxt)
f.close()



#print 'curl ' + baseUrl+repUrl+'/'+r.json()['resource']['reportUuid'] +  " -X POST -H \'" + json.dumps(headers) + "\' -d \'" + json.dumps(query) + "\'"

#Action,AdDescription,AdExtID,AdId,AdQuota,AdSizeRefId,AdTemplateDescription,AdTemplateExtID,AdType,AdvertiserID,AdvertiserName,AdvertiserType,AdWeight,Area,Ctr,FlightStartDate,DeviceType,FlightAbsoluteEndDate,FlightCapDescription,FlightCapExtID,FlightDescription,FlightEndDate,FlightExtId,FlightID,FlightLayer,FlightPrice,FlightTotalSales,ImpsGoal,Keyword,MccDescription,MediapointId,MediapointTAG,Netspeed,NL7Description,Click,Imps,OrderDescription,OrderExtId,OrderId,Position,UserProfiles,Publisher,Registration,Section,Site,Size,SmartPassback

print '---api-dot--video-te-se-qe-te-ve-be-ne-------------'







        
