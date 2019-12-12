#!/usr/local/bin/python2.7
import os
import sys
import getopt
import string
import urllib
import urllib2
import cookielib
import urlparse
import hashlib
import hmac
import base64
import calendar
import datetime

#right now the script only makes request to the SNV colo to make calls to other colos replace in below url snv by three letter colo string
serviceUrl1 = 'http://api.tags.bluekai.com/getdata/'
serviceUrl2 = '/v1.2?'
headers = {"Accept":"application/json","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
httpStr="GET"
def usage():
    print "\nThese are the usage functions:\n"
    print 'Usage-1: '+sys.argv[0]+ ' -s <sideid> [Required] -u <userid> -p <puserid> -f <pfield> -n <phint> -c <filterbycampids> -t <target> -b <bkuid> -k <bksecretkey> \n'
    print 'Usage-2: '+sys.argv[0]+ ' -s <siteid> [Required] -a "<useragent>" -i <ipaddress> -n <phint> -c <filterbycampids> -t <target> -b <bkuid> -k <bksecretkey> \n'
    print 'Usage-3: '+sys.argv[0]+ ' -s <siteid> [Required] -d <adid> -n <phint> -c <filterbycampids> -t <target> -b <bkuid> -k <bksecretkey> \n'
    print 'Usage-4: '+sys.argv[0]+ ' -s <siteid> [Required] -e <idfa> -n <phint> -c <filterbycampids> -t <target> -b <bkuid> -k <bksecretkey> \n'
    print "Params To send Data : phint\n"
    print "Params To get Data : filterbycampids, target\n"
def signatureInputBuilder(url, method, bkuid, bksecretkey):
    stringToSign = method
    parsedUrl = urlparse.urlparse(url)
    print parsedUrl
    stringToSign += parsedUrl.path
    # first split the query into array of parameters separted by the '&' character
    print parsedUrl.query
    qP = parsedUrl.query.split('&')
    print qP
    if len(qP) > 0:
        for  qS in qP:
            qP2 = qS.split('=', 1)
            #print qP2
            if len(qP2) > 1:
                stringToSign += qP2[1]

    print "stringToSign:" + stringToSign
    h = hmac.new(bksecretkey, stringToSign, hashlib.sha256)
    print "bksecretkey: " + bksecretkey
    print "stringToSign: " + stringToSign
    print "digest: " + h.hexdigest()
    s = base64.standard_b64encode(h.digest())
    print s

    u = urllib.quote_plus(s)
    print u
    newUrl = url
    if url.find('?') == -1 :
        newUrl += '?'
    else:
        newUrl += '&'

    newUrl += 'bkuid=' + bkuid + '&bksig=' + u
    return newUrl
def parseuastring(ua) :
    print "Test"
    print ua
    ua = ua.replace(" ","%20")
    return ua
def getUrlFromArgs(argv=sys.argv) :
    url = serviceUrl1
    bkuid_present = 0
    bksecretkey_present=0
    if(len(argv) == 0):
        usage()
        sys.exit(2)
    try:
        opts,args = getopt.getopt(argv, 's:b:k:u:p:f:n:c:t:a:i:d:e:h', ['siteid=','bkuid=','bksecretkey=','userid=','puserid=','pfield=','phint=','campIds=','targets=','useragent=','ipaddress=','adid','idfa','help'])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    for opt,arg in opts:
        if opt in ('-h', '--help'):
            usage()
            sys.exit(2)
        elif opt in ('-s', '--siteid'):
            siteid = arg
            url = url + str(siteid)
            url = url + serviceUrl2
        elif opt in ('-u', '--userid'):
            userid = arg
            url = url + "&userid=" + userid
        elif opt in ('-p', '--puserid'):
            puserid = arg
            url = url + "&puserid=" + puserid
        elif opt in ('-f', '--pfield'):
            pfield = arg
            url = url + "&pfield=" + pfield
        elif opt in ('-d','--adid'):
            adid = arg
            url = url + "&adid=" + adid
        elif opt in ('-e','--idfa'):
            idfa = arg
            url = url + "&idfa=" + idfa
        elif opt in ('-n', '--phint'):
            phint = arg
            url = url + "&phint=" + phint
        elif opt in ('-c', '--campIds'):
            campIds = arg
            url = url + "&filterbycampids=" + campIds
        elif opt in ('-t', '--target'):
            target = arg
            url = url + "&target=" + target
        elif opt in ('-a', '--useragent'):
            useragent = arg.replace(" ","%20")
            url = url + "&useragent=" + useragent
        elif opt in ('-i', '--ipaddress'):
            ipaddress = arg
            url = url + "&ipaddress=" + ipaddress
        elif opt in ('-b','--bkuid'):
            bkuid = arg
            bkuid_present = 1
        elif opt in ('-k','--bksecretkey'):
            bksecretkey = arg
            bksecretkey_present = 1
        else:
            usage()
            sys.exit(2)
    if bkuid_present and bksecretkey_present:
        url = signatureInputBuilder(url,httpStr,bkuid,bksecretkey)
        print "url=" + url
        url = str(url)
    return url
def doRequest(url):
  try:
      print "making HTTP request to "
      print url
      cJ = cookielib.CookieJar()
      request = urllib2.Request(url, None, headers)
      opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cJ))
      u = opener.open(request)
      rawData = u.read()
      print rawData
      print "200 ok"
      return rawData
  except urllib2.HTTPError, e:
      print "HTTP error: %d %s" % (e.code, str(e))
      print "ERROR: ", e.read()
      return None
  except urllib2.URLError, e:
      print "Network error: %s" % e.reason.args[1]
      print "ERROR: ", e.read()
      return None
def main(argv=sys.argv):
    url = getUrlFromArgs(argv)
    url = url.replace("?&","?")
    print url
    doRequest(url)
if __name__ == "__main__":
    main(sys.argv[1:])
