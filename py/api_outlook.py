##https://github.com/microsoftgraph/python3-connect-rest-sample
##https://docs.microsoft.com/en-us/outlook/rest/get-started
import json
import csv
import re
import time
import datetime
import numpy as np
import pandas as pd
import os
import json
import sys
import uuid
from openpyxl import Workbook, load_workbook
from io import BytesIO
import api_outlookLib as ol


print '-----------------------api-outlook--------------------------------'
key_file = os.environ['LAV_DIR'] + '/credenza/outlook.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)

codeS = open(os.environ['LAV_DIR'] + 'credenza/outlook_cert.pfx').read()
headers = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}

codeS = open(os.environ['LAV_DIR'] + 'credenza/outlook_cert.pfx').read()

if False: #first access
    loginUrl = 'https://login.microsoftonline.com/'
    sData = {"client_id":cred['app_id'],"redirect_uri":cred['redirect_uri'],"response_type":"code"}
    resq = requests.get(loginUrl+"common/oauth2/v2.0/authorize&scope=openid+Mail.Read",params=sData)

    authority = 'https://login.microsoftonline.com'
    authorize_url = '{0}{1}'.format(authority,'/common/oauth2/v2.0/authorize?{0}')
    token_url = '{0}{1}'.format(authority,'/common/oauth2/v2.0/token')
    scopes = ['openid','User.Read','Mail.Read','offline_access']
    params = {'client_id': cred['app_id'],'redirect_uri': cred['redirect_uri'],'response_type': 'code','scope': ' '.join(str(i) for i in scopes)}
    signin_url = authorize_url.format(urllib.urlencode(params))
    resq = requests.get(signin_url,headers=headers)
    print resq.url
    # import xmltodict
    # print xmltodict.parse(resq.text)['html']['body']
    sData = {"client_id":cred['app_id'],"client_secret":cred["pass"],"code":cred["code"],"redirect_uri":cred["redirect_uri"],"grant_type":"authorization_code"}
    resq = requests.post(loginUrl+"common/oauth2/v2.0/token",data=sData,headers=headers)
    token = resq.json()['refresh_token']
    print token

def getToken(cred):
    headers = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
    sData = {"grant_type":"refresh_token","refresh_token":cred["token"]["refresh_token"],"client_id":cred["app_id"],"client_secret":cred["pass"],"redirect_uri":cred["redirect_uri"]}#,"resource":"https://outlook.office365.com/"
    resq = requests.post(loginUrl+"common/oauth2/v2.0/token",data=sData,headers=headers)
    try:
        cred['token'] = resq.json()
        with open(os.environ['LAV_DIR']+"/credenza/outlook.json",'w') as outfile:
            json.dump(cred, outfile,indent=2)
            return resq.json()['access_token']
    except:
        print resq.status_code, resq.text

token = getToken(cred)

headers = {"ContentType":"application/json;odata=verbose","Authorization":"Bearer "+token}
resq = requests.get(baseUrl+"mailfolders/inbox/childfolders",headers=headers)
folderL = resq.json()['value']
folderId = [x['displayName'] in "doc" for x in folderL]
folderId = folderL[[i for i, x in enumerate(folderId) if x][0]]['id']
resq = requests.get(baseUrl+"mailfolders/"+folderId,headers=headers)
print resq.text
    
baseUrl = "https://graph.microsoft.com/v1.0/me/"
date = "2017-07-21"
headers = {"ContentType":"application/json;odata=verbose","Authorization":"Bearer "+token}
sData = {"$select":"subject,from,receivedDateTime","$top":25,"$filter":"HasAttachments eq true and receivedDateTime ge " + date }#,"$orderby":"receivedDateTime%20DESC"}
resq = requests.get(baseUrl+"mailfolders/"+folderId+"/messages",params=sData,headers=headers)
try:
    mailL = resq.json()['value']
except:
    print resq.status_code, resq.text


i=0
for i in range(len(mailL)):
    resq = requests.get(baseUrl+"mailfolders/"+folderId+"/messages/"+mailL[i]["id"]+"/attachments?$select=Name",headers=headers)
    if resq.status_code >= 400:
        print resq.text
    attL = resq.json()['value']
    for att in attL:
        if any([x in att['name'] for x in ["csv","xls","xlsx"]]):
            print att['id']
            fName = att['name']
            resq = requests.get(baseUrl+"mailfolders/inbox/messages/"+mailL[i]["id"]+"/attachments/"+att['id']+"",headers=headers)
            spreadSheet = resq.json()['contentBytes']
            open("/tmp/"+fName,'wb').write(spreadSheet)

            wb = load_workbook(spreadSheet)
            print resq.json()['contentType']

