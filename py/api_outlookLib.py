##https://github.com/microsoftgraph/python3-connect-rest-sample
import urllib
import urllib2
import cookielib
import base64
import requests
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
# un-comment these lines to suppress the HTTP status messages sent to the console
#import logging
#logging.getLogger('werkzeug').setLevel(logging.ERROR)
from flask import Flask, redirect, url_for, session, request, render_template
from flask_oauthlib.client import OAuth
import flask_script
from openpyxl import Workbook, load_workbook
from io import BytesIO

print '-----------------------api-outlook--------------------------------'
headers = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}

def firstAccess():
    key_file = os.environ['LAV_DIR'] + '/credenza/outlook.json'
    cred = []
    with open(key_file) as f:
        cred = json.load(f)
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

def getToken():
    key_file = os.environ['LAV_DIR'] + '/credenza/outlook.json'
    cred = []
    with open(key_file) as f:
        cred = json.load(f)
    loginUrl = 'https://login.microsoftonline.com/'
    headers = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
    sData = {"grant_type":"refresh_token","refresh_token":cred["token"]["refresh_token"],"client_id":cred["app_id"],"client_secret":cred["pass"],"redirect_uri":cred["redirect_uri"]}#,"resource":"https://outlook.office365.com/"
    resq = requests.post(loginUrl+"common/oauth2/v2.0/token",data=sData,headers=headers)
    try:
        cred['token'] = resq.json()
        with open(os.environ['LAV_DIR']+"/credenza/outlook.json",'w') as outfile:
            json.dump(cred, outfile,indent=2)
            token = resq.json()['access_token'] 
            headers = {"ContentType":"application/json;odata=verbose","Authorization":"Bearer "+token}
            return headers
    except:
        print resq.status_code, resq.text


def getFolderId(headers):
    baseUrl = "https://graph.microsoft.com/v1.0/me/"
    resq = requests.get(baseUrl+"mailfolders/inbox/childfolders",headers=headers)
    folderL = resq.json()['value']
    folderId = [x['displayName'] in "doc" for x in folderL]
    folderId = folderL[[i for i, x in enumerate(folderId) if x][0]]['id']
    return folderId

def getAttList(headers):
    baseUrl = "https://graph.microsoft.com/v1.0/me/"
    date = "2017-07-21"
    sData = {"$select":"subject,from,receivedDateTime","$top":25,"$filter":"HasAttachments eq true and receivedDateTime ge " + date }#,"$orderby":"receivedDateTime%20DESC"}
    folderId = getFolderId(headers)
    resq = requests.get(baseUrl+"mailfolders/"+folderId+"/messages",params=sData,headers=headers)
    try:
        mailL = resq.json()['value']
    except:
        print resq.status_code, resq.text
    i=0
    j=0
    attL = dict()
    for i in range(len(mailL)):
        print mailL[i]["subject"]
        resq = requests.get(baseUrl+"mailfolders/"+folderId+"/messages/"+mailL[i]["id"]+"/attachments?$select=Name",headers=headers)
        if resq.status_code >= 400:
            print resq.text
        attL1 = resq.json()['value']
        attId = [any([x['name'].find(y) > 0 for y in ["csv","xls","xlsx"]]) for x in attL1]
        if not any(attId):
            continue
        print 'with attachments', i
        lineD = {"folder":folderId,"mail_id":mailL[i]["id"],"mail_name":mailL[i]["subject"],"att_l":[[attL1[i]['id'],attL1[i]['name']] for i,x in enumerate(attId) if x][0]}
        attL[j] = lineD
        j = j + 1
    return attL


def parseReport(headers):
    baseUrl = "https://graph.microsoft.com/v1.0/me/"
    attL = getAttList(headers)
    headers['ContentType'] = "application/vnd.ms-excel"
    headers['ContentType'] = "application/json"
    att = attL[0]
    for i,att in enumerate(attL):
        print att
        attF = att['att_l']
        fName = attF[1]
        resq = requests.get(baseUrl+"mailfolders/"+att["folder"]+"/messages/"+att["mail_id"]+"/attachments/"+attF[0]+"",headers=headers)
        print resq.json()['contentType']
        print resq.json()['name']
        
        spreadSheet = resq.json()['contentBytes']
        open("/tmp/"+fName,'wb').write(spreadSheet)

        wb = load_workbook(spreadSheet)
        print resq.json()['contentType']


headers = getToken()

