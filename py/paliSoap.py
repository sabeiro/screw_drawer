from suds.client import Client
import pandas as pd
import json
# import pprint
# from suds.wsse import *
# from datetime import timedelta,date,datetime,tzinfo
import requests
from requests.auth import HTTPBasicAuth
import suds_requests
# import zeep
# import logging
# logging.basicConfig(level=logging.INFO)
# logging.getLogger('suds.client').setLevel(logging.DEBUG)
# from suds.sudsobject import asdict

def recursive_translation(d):
    result = {}
    for k, v in asdict(d).iteritems():
        if hasattr(v, '__keylist__'):
            result[k] = recursive_translation(v)
        elif isinstance(v, list):
            result[k] = []
            for item in v:
                if hasattr(item, '__keylist__'):
                    result[k].append(recursive_translation(item))
                else:
                    result[k].append(item)
        else:
            result[k] = v
    return result

soap_url = 'http://osb11g.mediaset.it:8021/PalinsestiOSB/PS/PS_MHPService?wsdl'
wsdl_url = 'http://analisi.ad.mediamond.it/data/paliReq.wsdl'
##wsdl_url = 'file://home/sabeiro/lav/media/intertino/data/paliReq.wsdl'
username=''
password=''

def addSecurityHeader(client,username,password):
    security=Security()
    userNameToken=UsernameToken(username,password)
    timeStampToken=Timestamp(validity=600)
    security.tokens.append(userNameToken)
    security.tokens.append(timeStampToken)
    client.set_options(wsse=security)

session = requests.session()
session.auth=(username, password)
client = Client(url=soap_url,location=wsdl_url,faults=False,cachingpolicy=1,transport=suds_requests.RequestsTransport(session))
print client
chN = "C5"
chN = "R4"
chN = "I1"
#pprint(client)
client = Client(soap_url)
pali = client.service.getMHPData(chN,"01/01/2016 00:03:00","31/12/2016 06:00:00",5)
print 'ciccia'
paliL = list()
for i in range(0,pali.__len__()):
    palii = pali.__getitem__(i)
    paliL.append({"name":palii.__getitem__(0),"time":palii.__getitem__(4),"type":palii.__getitem__(20),"genre":palii.__getitem__(26),"replica":palii.__getitem__(10)})

paliDf = pd.DataFrame(paliL)
print paliDf
paliDf.to_csv("../../raw/paliSoap"+chN+".csv",encoding='utf-8')



    
##json.loads(r.read().decode(r.info().getparam('charset') or 'utf-8'))  

# type()
# dir()
# id()
# getattr()
# hasattr()
# globals()
# locals()
# callable()


# client = zeep.Client(wsdl=soap_url)
# print(client.service.Method1('Zeep','is cool'))
# service = client.create_service('{http://my-target-namespace-here}myBinding','http://my-endpoint.com/acceptance/')
# service.submit('something')



