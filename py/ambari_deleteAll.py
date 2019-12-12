import os
import sys
sys.path.append("/home/sabeiro/lav/media/script/py/")
import requests
import random
import json
import numpy as np
import pandas as pd
##import urllib
import urllib2, base64
import cookielib
import urlparse

key_file = '../../credenza/ambari_env.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)

headers = {"Accept":"application/json","Content-type":"application/json","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5","X-Requested-By":"ambari"}
headers = {'X-Requested-By': 'ambari'}
data = '{"RequestInfo":{"context":"Stop Service"},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}'
data = '{}'

url='http://'+cred['AMBARI_SERVER_HOST']+':8080/api/v1/clusters/'+cred['CLUSTER']+'/hosts/'+cred['HOSTNAME']
req = requests.get(url, headers=headers, auth=(cred['AMBARI_USER'],cred['AMBARI_PASS']))
resp = json.loads(req.content)
for comp in resp['host_components']:
    print comp['href']
    requests.delete(comp['href'], headers=headers, auth=(cred['AMBARI_USER'],cred['AMBARI_PASS']))

  
url='http://'+cred['AMBARI_SERVER_HOST']+':8080/api/v1/hosts/'+cred['HOSTNAME']  
requests.delete(comp['href'], headers=headers, auth=(cred['AMBARI_USER'],cred['AMBARI_PASS']))


# request = urllib2.Request(url, data, headers)
# base64string = base64.encodestring('%s:%s' % (cred['AMBARI_USER'],cred['AMBARI_PASS'])).replace('\n', '')
# request.add_header("Authorization", "Basic %s" % base64string)   
# cJ = cookielib.CookieJar()
# result = urllib2.urlopen(request)

# opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cJ))
# u = opener.open(request)
# rawData = u.read()
 
