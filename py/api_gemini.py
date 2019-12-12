##https://developer.yahoo.com/brightroll/dsp/api/docs/authentication/
##https://developer.yahoo.com/apps/0TH8345e/
import urllib
import urllib2
import cookielib
import base64
import requests
import json
import csv
import re
import time
import numpy as np
import pandas as pd

baseUrl = 'https://api.login.yahoo.com/oauth2/'

headers = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
headers = {"Authorization":"Basic "+base64.standard_b64encode(cred['client_id']+":"+cred['client_secret']),"Content-Type":"application/x-www-form-urlencoded"}

sData = {"params": {},"version": "1.1","method": "getConnectionTest"}
key_file = '../../credenza/gemini2.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)

sData = {"client_id":cred['client_id'],"redirect_uri":"oob","response_type":'code',"language":"en-us"}
sData = {"client_id":cred['client_id'],"redirect_uri":cred['callback_domain']+'/oauth2/gemini.php',"response_type":'code',"language":"en-us"}
authUrl = baseUrl+'request_auth?'+urllib.urlencode(sData)

resq = requests.get(authUrl)

sData = {"client_id":cred['client_id'],"client_secret":cred['client_secret'],"redirect_uri":"http://"+cred['callback_domain']+"/oauth2/gemini.php","code":cred['app_code'],"grant_type":"authorization_code"}
##"http%3A%2F%2F"+
resq = requests.post(baseUrl+'get_token'+'?'+urllib.urlencode(sData),headers=headers,data=json.dumps(sData,separators=(',', ':')))
print resq.json()

print 'curl ' + baseUrl+'get_token' +  " -X POST -H \'" + json.dumps(headers,separators=(',', ':')) + "\' -d \'" + json.dumps(sData,separators=(',', ':')) + "\'"

#https://developer.yahoo.com/oauth2/guide/flows_authcode/#refresh-token-label=



headers['Content-Type'] = "application/json"
sData = {"grant_type":cred['refresh_token'],"redirect_uri":cred['callback_domain'],"refresh_token":cred['refresh_token']}
resq = requests.post(baseUrl+'get_token',headers=headers,data=json.dumps(sData))
print resq.json()
token = resq.json()['access_token']
headers = {"Content-Type":"application/json","X-Auth-Method":"OAUTH","X-Auth-Token":token}
sData = {"reportOption": {
    "timezone": "Europe/Paris",
    "currency": 3,
    "dimensionTypeIds": [4,5,],#39
    "metricTypeIds": [1,2,23,44,46]
},
         "intervalTypeId": 1,
         "dateTypeId": 2,
         "startDate": "2017-03-10T00:00:00-05:00",
         "endDate": "2017-03-10T11:59:59-05:00"
}
baseUrl = "http://api-sched-v3.admanagerplus.yahoo.com/yamplus_api/extreport/"
resq = requests.post(baseUrl,headers=headers, data=json.dumps(sData))
print resq.json()
repId = resq.json()['customerReportId']

##GET https://api.admanager.yahoo.com/v1/rest/campaign/31336
resq = requests.post(baseUrl,headers=headers, data=json.dumps({}))


print resq.json()['status']
stat = ""
counter = 1
while stat not in ["Success",401]:
        resq = requests.get("https://api-sched-v3.admanagerplus.yahoo.com/yamplus_api/extreport/"+repId,headers=headers)
        stat = resq.json()['status']
        time.sleep(.5)
        counter += 1
        if(counter > 100):
            break

print stat

        
repLink = resq.json()['url']
print stat
resq = requests.get(repLink,headers=headers)
content = resq.text.encode('utf-8')
cr = csv.reader(content.splitlines(), delimiter=',')
cr_list = list(cr)
campL = []
for row in cr_list:
    campL.append(row)


sData = {"id": 1,"currency": "USD","timezone": "America/New_York","advertiserName": "advertiser1"}
resq = requests.post("https://api.gemini.yahoo.com/v2/rest/advertiser/",headers=headers,data=json.dumps(sData))
print resq._content

resq = requests.post("https://api.gemini.yahoo.com/v2/rest/advertiser/87292",headers=headers,data=json.dumps(sData))
print resq._content


https://api.gemini.yahoo.com/v2/rest/advertiser/?id=134&id=19426

https://api.gemini.yahoo.com/v2/rest/advertiser/?mr=5

https://api.login.yahoo.com/oauth/v2/  
  get_request_token?oauth_nonce=ce2130523f788f313f76314ed3965ea6  
  &oauth_timestamp=1202956957  
  &oauth_consumer_key=123456891011121314151617181920  
  &oauth_signature_method=plaintext  
  &oauth_signature=abcdef  
  &oauth_version=1.0  
  &xoauth_lang_pref="en-us"  
  &oauth_callback="http://yoursite.com/callback"


HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create("http://query.yahooapis.com/v1/yql?q=select%20fields.value%20from%20social.contacts%20where%20guid%3Dme&diagnostics=false");
request.Headers.Add(
    "Authorization: OAuth " +
    "realm=\"" + "yahooapis.com" + "\"," +
    "oauth_consumer_key=\"" + ConfigurationManager.AppSettings["yahoo_oauth_consumer_key"] + "\"," +
    "oauth_nonce=\"" + Guid.NewGuid().ToString() + "\"," +
    "oauth_signature_method=\"" + "PLAINTEXT" + "\"," +
    "oauth_timestamp=\"" + ((DateTime.UtcNow.Ticks - new DateTime(1970, 1, 1).Ticks) / (1000 * 10000)).ToString() + "\"," +
    "oauth_token=\"" + accessToken.TokenValue + "\"," +
    "oauth_version=\"1.0" + "\"," +
    "oauth_signature=\"" + ConfigurationManager.AppSettings["yahoo_oauth_signature"] + "%26" + "\""
);
StreamReader streamReader = new StreamReader(request.GetResponse().GetResponseStream(), true);
