import api_dotLib as dot
import numpy as np
import pandas as pd
import clipboard
import re
import StringIO

token = dot.getToken()
dataQ = ["2017-02-06","2017-02-12"]
headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
##tappi
query = {"token":token,
    "request":{
        "reportId":"MD",
        "fields":[{"id":"Date","sortd":"desc","sortp":1,"filters":[[{"op":">=","v": [dataQ[0]]}],[{"op":"<=","v": [dataQ[1]]}]]}
        ,{"id":"Size","visible": False,"sortp":2,"filters":[[{"op":"=","v": ["SPOT"]}]]}
        ,{"id":"Publisher","visible": False,"sortp":3,"filters":[[{"op":"=","v": ["WEBTV"]}]]}
        ,{"id":"FlightDescription","visible": False,"sortp":4,"filters":[[{"op":"CONTAINS","v": ["Tapp"]}]]}
        ,{"id":"Imps"}
        ]
    }
}
#headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
rep = dot.waitRep(token,query,headers)
tappi = dot.formRep(rep.content)
#default
query = {"token":token,
    "request":{
        "reportId":"MD",
        "fields":[{"id":"Date","sortd":"desc","sortp":1,"filters":[[{"op":">=","v": [dataQ[0]]}],[{"op":"<=","v": [dataQ[1]]}]]}
        ,{"id":"Size","visible": False,"sortp":2,"filters":[[{"op":"=","v": ["SPOT"]}]]}
        ,{"id":"Publisher","visible": False,"sortp":3,"filters":[[{"op":"=","v": ["WEBTV"]}]]}
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
        ,{"id":"Publisher","visible": False,"sortp":3,"filters":[[{"op":"=","v": ["WEBTV"]}]]}
        ,{"id":"Site","sortp":3,"visible": False,"filters":[[{"op":"=","v": ["VIDEOEXTRA"]}]]}
        ,{"id":"AdvertiserType","visible": False,"sortp":4,"filters":[[{"op":"=","v": ["Default"]}]]}
        ,{"id":"Imps"}
        ]
    }
}
headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
rep = dot.waitRep(token,query,headers)
adPass = dot.formRep(rep.content)

[x for x in adType if x[1] == "Paganti"][0]

weekD = ("Sunday","Saturday","Friday","Thursday","Wednesday","Tuesday","Monday")
videoL = []
for d in range(0,len(tappi)):
    autoP = int(adType[d*3+0][2])
    default = int(adType[d*3+1][2]) - int(adPass[d][1])
    paid = int(adType[d*3+2][2])
    tapp = int(tappi[d][1])
    dLine = (tappi[d][0],weekD[d],paid,default,autoP,tapp,default+autoP+tapp,paid+default+autoP,tappi[len(tappi)-1][0])
    videoL.append(dLine)
videoD = pd.DataFrame(videoL)
videoD.rename(columns={0:"data",1:"weekD",2:"Paganti",3:"Default",4:"Autopromo",5:"Tappi",6:"Invenduto",7:"Totale inventory",8:"week"},inplace=True)
print videoD
videoDW = videoD.groupby(["week"]).sum()
print videoDW
print videoDW['Invenduto']/videoDW['Totale inventory']


buff = StringIO.StringIO()
videoD.to_csv(buff,header=False, index=False)
buff.seek(0)
output = buff.getvalue()
buff.close()
clipboard.copy(output)

#section
query = {"token":token,
    "request":{
        "reportId":"MD",
        "fields":[{"id":"Date","sortd":"desc","sortp":1,"filters":[[{"op":">=","v": [dataQ[0]]}],[{"op":"<=","v": [dataQ[1]]}]]}
        ,{"id":"Size","visible": False,"sortp":2,"filters":[[{"op":"=","v": ["SPOT"]}]]}
        ,{"id":"Publisher","visible": False,"sortp":3,"filters":[[{"op":"=","v": ["WEBTV"]}]]}
        ,{"id":"Section","sort":"asc","sortp":3}
        ,{"id":"Imps"}
        ]
    }
}
headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
rep = dot.waitRep(token,query,headers)
adSect =  pd.DataFrame(dot.formRep(rep.content))
adSect.rename(columns={0:"data",1:"section",2:"imps"},inplace=True)

adSect['group'] = 'rest'
adSect['imps'] = adSect['imps'].apply(lambda x: pd.to_numeric(x,errors="ignore"))
adSect['imps'] = pd.to_numeric(adSect['imps'])
sectL = pd.read_csv("../../raw/inventoryVideoSection.csv")
for i in range(0,len(sectL)):
    idxA = adSect['section'].str.contains(str(sectL['canale'][i]))
    adSect['group'][idxA] = str(sectL['cluster'][i])

adWeek = adSect.groupby(["group"]).sum()
print adWeek.sort_values('imps',ascending=False)
buff = StringIO.StringIO()
adWeek.to_csv(buff,header=False, index=False)
buff.seek(0)
output = buff.getvalue()
buff.close()
clipboard.copy(output)

sectImps = adSect.groupby(["section"]).sum()
sectImps = sectImps.sort_values('imps',ascending=False)
print sectImps[0:5]
buff = StringIO.StringIO()
sectImps[0:20].to_csv(buff,header=False)#, index=False)
buff.seek(0)
output = buff.getvalue()
buff.close()
clipboard.copy(output)


query = {"token":token,
    "request":{
        "reportId":"MD",
        "fields":[{"id":"Date","sortd":"desc","sortp":1,"filters":[[{"op":">=","v": [dataQ[0]]}],[{"op":"<=","v": [dataQ[1]]}]]}
        ,{"id":"Size","visible": False,"sortp":2,"filters":[[{"op":"=","v": ["SPOT"]}]]}
        ,{"id":"Publisher","visible": False,"sortp":3,"filters":[[{"op":"=","v": ["WEBTV"]}]]}
        ,{"id":"Site","sortp":3,"visible": False,"filters":[[{"op":"=","v": ["LIVE"]}]]}
        ,{"id":"Imps"}
        ]
    }
}
headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
rep = dot.waitRep(token,query,headers)
adLive = pd.DataFrame(dot.formRep(rep.content))
adLive[1] = pd.to_numeric(adLive[1])
print 'live: ' + str(adLive[1].sum())



# import MySQLdb
# from pandas.io import sql
# MySQLdb.connect("localhost","root","","db" )
# df.to_sql('df',sql_cnxn,flavor='mysql',if_exists='replace', chunksize=100)

#print 'curl ' + baseUrl+repUrl+'/'+r.json()['resource']['reportUuid'] +  " -X POST -H \'" + json.dumps(headers) + "\' -d \'" + json.dumps(query) + "\'"

#Action,AdDescription,AdExtID,AdId,AdQuota,AdSizeRefId,AdTemplateDescription,AdTemplateExtID,AdType,AdvertiserID,AdvertiserName,AdvertiserType,AdWeight,Area,Ctr,FlightStartDate,DeviceType,FlightAbsoluteEndDate,FlightCapDescription,FlightCapExtID,FlightDescription,FlightEndDate,FlightExtId,FlightID,FlightLayer,FlightPrice,FlightTotalSales,ImpsGoal,Keyword,MccDescription,MediapointId,MediapointTAG,Netspeed,NL7Description,Click,Imps,OrderDescription,OrderExtId,OrderId,Position,UserProfiles,Publisher,Registration,Section,Site,Size,SmartPassback



