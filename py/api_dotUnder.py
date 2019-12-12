import sys
sys.path.append("~/lav/media/src/py/")
import api_dotLib as dot
import numpy as np
import pandas as pd
##import clipboard
import re
import StringIO
import time
import datetime
import json
import MySQLdb
from pandas.io import sql
import sqlalchemy
from urllib import quote_plus as urlquote
import os

##----------------------extract-------------------------------------------
print '-------------------------------api-dot---------------------------------'

token = dot.getToken()
dataQ = ["2017-04-07","2017-04-08"]
dataQ = [(datetime.date.today() - datetime.timedelta(days=1)).strftime("%Y-%m-%d"),(datetime.date.today() - datetime.timedelta(days=1)).strftime("%Y-%m-%d")]
headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
##tappi
query = {"token":token
    ,"request":{"status":1}
    ,"pagination":{"rowNumber":100,"page":1}
}
headers = {"Content-Type":"application/json"}
rep = dot.flightList(query,headers)

#print 'curl -X POST ' +  baseUrl+flightUrl + " --data '" + json.dumps(query) + "'" +  ' --header "Content-Type:application/json"'


rep = dot.waitRep(token,query,headers)
tappi = dot.formRep(rep.content)
#default
query = {"token":token,
    "request":{
        "reportId":"MD",
        "fields":[{"id":"Date","sortd":"desc","visible":True,"sortp":1,"filters":[[{"op":">=","v": [dataQ[0]]}],[{"op":"<=","v": [dataQ[1]]}]]}
        ,{"id":"Size","visible": False,"sortp":2,"filters":[[{"op":"=","v": ["SPOT"]}]]}
        ,{"id":"Publisher","visible": False,"sortp":3,"filters":[[{"op":"=","v": ["WEBTV"]}]]}
        ,{"id":"AdvertiserType","visible":True,"sortd":"asc","sortp":4}
        ,{"id":"Imps"}
        ]
    }
}
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

##[x for x in adType if x[1] == "Paganti"][0]

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


##------------------------transform-----------------------------------

weekD = ("Sunday","Saturday","Friday","Thursday","Wednesday","Tuesday","Monday")
videoL = []
weekDate = tappi[0][0]
for d in range(0,len(tappi)):
    autoP = int(adType[d*3+0][2])
    default = int(adType[d*3+1][2]) - int(adPass[d][1])
    paid = int(adType[d*3+2][2])
    tapp = int(tappi[d][1])
    year, month, day = (int(x) for x in tappi[d][0].split('-'))
    lDay = weekD[datetime.date(year, month, day).weekday()]
    if lDay == "Monday":
        weekDate = tappi[d][0]
    dLine = (tappi[d][0],lDay,paid,default,autoP,tapp,default+autoP+tapp,paid+default+autoP,weekDate)
    videoL.append(dLine)

videoD = pd.DataFrame(videoL)
videoD.rename(columns={0:"data",1:"weekD",2:"Paganti",3:"Default",4:"Autopromo",5:"Tappi",6:"Invenduto",7:"Totale inventory",8:"week"},inplace=True)
videoD.set_index("data",inplace=True)

adSect['group'] = 'rest'
adSect['imps'] = adSect['imps'].apply(lambda x: pd.to_numeric(x,errors="ignore"))
adSect['imps'] = pd.to_numeric(adSect['imps'])
sectL = pd.read_csv(os.environ['LAV_DIR'] + "/raw/inventoryVideoSection.csv")
for i in range(0,len(sectL)):
    idxA = adSect['section'].str.contains(str(sectL['canale'][i]))
    adSect['group'][idxA] = str(sectL['cluster'][i])

adWeek = adSect.groupby(["data","group"]).sum().unstack()

##------------------------load-----------------------------------

##from pandasql import sqldf
key_file = os.environ['LAV_DIR'] + '/credenza/intertino.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)

cred = cred['mysql']['intertino']

# conn = MySQLdb.connect(cred['host'],cred['user'],cred['pass'],cred['db'])
# cursor = conn.cursor()
# videoDb = pd.read_sql("SELECT * from inventory_video_dot",conn)
# query = "DROP TABLE inventory_video_daily"
# query = """CREATE TABLE `intertino`.`inventory_video_daily` ( `date` DATE NULL , `wday` VARCHAR(20) NOT NULL , `paganti` INT NOT NULL , `default` INT NOT NULL , `autopromo` INT NOT NULL , `tappi` INT NOT NULL , `invenduto` INT NOT NULL , `tot` INT NOT NULL , `week` DATE NULL ,PRIMARY KEY (`date`)) ENGINE = InnoDB;"""
#query = """CREATE TABLE `intertino`.`inventory_video_section` ( `date` DATE NULL , `paganti` INT NOT NULL , `default` INT NOT NULL , `autopromo` INT NOT NULL , `tappi` INT NOT NULL , `invenduto` INT NOT NULL , `tot` INT NOT NULL , `week` DATE NULL ,PRIMARY KEY (`date`)) ENGINE = InnoDB;"""
# cursor.execute(query)
# conn.close()
engine = sqlalchemy.create_engine('mysql://'+cred['user']+':'+cred['pass']+'@'+cred['host']+'/'+cred['db'],echo=False)
conn = engine.connect()
videoD.to_sql('inventory_video_daily',conn,if_exists='append',chunksize=100)
adWeek.imps.to_sql('inventory_video_section',conn,if_exists='append',chunksize=100)
conn.close()

#print 'curl ' + baseUrl+repUrl+'/'+r.json()['resource']['reportUuid'] +  " -X POST -H \'" + json.dumps(headers) + "\' -d \'" + json.dumps(query) + "\'"

#Action,AdDescription,AdExtID,AdId,AdQuota,AdSizeRefId,AdTemplateDescription,AdTemplateExtID,AdType,AdvertiserID,AdvertiserName,AdvertiserType,AdWeight,Area,Ctr,FlightStartDate,DeviceType,FlightAbsoluteEndDate,FlightCapDescription,FlightCapExtID,FlightDescription,FlightEndDate,FlightExtId,FlightID,FlightLayer,FlightPrice,FlightTotalSales,ImpsGoal,Keyword,MccDescription,MediapointId,MediapointTAG,Netspeed,NL7Description,Click,Imps,OrderDescription,OrderExtId,OrderId,Position,UserProfiles,Publisher,Registration,Section,Site,Size,SmartPassback



