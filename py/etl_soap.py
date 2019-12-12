from suds.client import Client
import pandas as pd
import os
import json
import pprint
# from suds.wsse import *
# from datetime import timedelta,date,datetime,tzinfo
import requests
from requests.auth import HTTPBasicAuth
import suds_requests
# Import zeep
# import logging
# logging.basicConfig(level=logging.INFO)
# logging.getLogger('suds.client').setLevel(logging.DEBUG)
# from suds.sudsobject import asdict

key_file = os.environ['LAV_DIR'] + '/credenza/medianet.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)['soap']

# session = requests.session()
# session.auth=(cred['username'],cred['password'])
# client = Client(url=cred['url'],location=cred['wsdl'],faults=False,cachingpolicy=1,transport=suds_requests.RequestsTransport(session))
chL = ["C5","R4","I1"]
#print(client)
client = Client(cred['url'])
for ch in chL:
    print ch
    pali = client.service.getMHPData(ch,"01/01/2017 00:03:00","31/12/2017 06:00:00",5)
    paliL = list()
    for i in range(0,pali.__len__()):
        palii = pali.__getitem__(i)
        paliL.append({"name":palii.__getitem__(0),"time":palii.__getitem__(4),"type":palii.__getitem__(20),"genre":palii.__getitem__(26),"replica":palii.__getitem__(10)})
    paliDf = pd.DataFrame(paliL)
    paliDf.to_csv(os.environ['LAV_DIR'] + "/raw/paliSoap2017"+ch+".csv",encoding='utf-8')


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



