import urllib
import urllib2
import cookielib
import urlparse
import hashlib
import hmac
import base64
import json
import random
import unicodedata
import os
#import logging

key_file = os.environ['LAV_DIR'] + '/credenza/bluekai.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)
bkuid = unicodedata.normalize('NFKD',cred['json']['bkuid']).encode('ascii','ignore') 
bksecretkey =  unicodedata.normalize('NFKD',cred['json']['bksecretkey']).encode('ascii','ignore')

headers = {"Accept":"application/json","Content-type":"application/json","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}

def signatureInputBuilder(url, method, data):
    stringToSign = method
    parsedUrl = urlparse.urlparse(url)
    print parsedUrl
    stringToSign += parsedUrl.path
    qP = parsedUrl.query.split('&')
    #print qP
    if len(qP) > 0:
        for  qS in qP:
            qP2 = qS.split('=')
            #print qP2
            if len(qP2) > 1:
                stringToSign += qP2[1]
    if data != None :
        stringToSign += data
    h = hmac.new(bksecretkey, stringToSign, hashlib.sha256)
    s = base64.standard_b64encode(h.digest())
    u = urllib.quote_plus(s)
    newUrl = url
    if url.find('?') == -1 :
        newUrl += '?'
    else:
        newUrl += '&'
    newUrl += 'bkuid=' + bkuid + '&bksig=' + u
    return newUrl

def doRequest(url, method, data):
    try:
        cJ = cookielib.CookieJar()
        request = None
        if method == 'PUT':
            request = urllib2.Request(url, data, headers)
            request.get_method = lambda: 'PUT'
        elif  method == 'DELETE' :
            request = urllib2.Request(url, data, headers)
            request.get_method = lambda: 'DELETE'
        elif data != None :
            request = urllib2.Request(url, data, headers)
        else:
            request = urllib2.Request(url, None, headers) 
        opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cJ))
        u = opener.open(request)
        rawData = u.read()
        print "-- 200 --"
        ##print "\nAPI Response:\n" + rawData + "\n"
        return rawData
    except urllib2.HTTPError, e:
        print "\nHTTP error: %d %s" % (e.code, str(e))
        print "ERROR: ", e.read()
        return None
    except urllib2.URLError, e:
        print "Network error: %s" % e.reason.args[1]
        print "ERROR: ", e.read()
        return None

