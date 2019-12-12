import urlparse,urllib,urllib2,requests,cookielib
import base64
import json,gzip,zlib,sys,csv
import time
import StringIO
import os

reload(sys)
sys.setdefaultencoding('utf8')

headers = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
baseUrl = 'http://api.dashboard.ad.dotandad.com:9190'
credUrl = '/api/v1/token'
repUrl = '/api/v1/reports'
flightUrl = '/api/v1/flights'
posUrl = '/api/v1/sizesPositions'
revUrl = '/api/v1/reports/monetization/'
key_file = os.environ['LAV_DIR'] + '/credenza/dotandmedia.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)
def getToken():
    sData = {"params": {},"version": "1.1","method": "getConnectionTest"}
    resp = requests.post(baseUrl+credUrl,headers=headers,data=json.dumps(cred))
    return resp.json()['resource']['token']

def waitRep(token,query,headers):
    r = requests.post(baseUrl+repUrl,headers=headers,data=json.dumps(query,separators=(',', ':')))
    print(r.status_code,r.reason,r.text)
    headers = {"Content-type":"application/x-www-form-urlencoded"}
    query = {"token":token}
    url = baseUrl+repUrl+'/'+r.json()['resource']['reportUuid']
    counter = 1
    stat = 404
    while stat not in [200,401,500]:
        rep = requests.post(url,data=json.dumps(query,separators=(',',':')),headers=headers)
        stat = int(rep.status_code)
        time.sleep(6)
        counter += 1
        if(counter > 60*4):
            print 'timeout'
            break
        print(rep.status_code,rep.reason,counter)
    return rep
    
def formRep(zipped):
    content = gzip.GzipFile(fileobj=StringIO.StringIO(zipped)).read()
    cr = csv.reader(content.splitlines(),delimiter=',')
    cr_list = list(cr)
    campL = []
    for row in cr_list:
        campL.append(row)
    return campL
    ##content = zlib.decompress(zipped)##decode('utf-8')
    # fo = open("ciccia.tar.gz","w")
    # fo.write(rep.content)


def flightList(query,headers):
    r = requests.post(baseUrl+flightUrl,headers=headers,data=json.dumps(query))
    print(r.status_code,r.reason)
    return r


def wrBuffer(df):
    buff = StringIO.StringIO()
    df.to_csv(buff)
    buff.seek(0)
    output = buff.getvalue()
    txt = str(output)
    buff.close()
    return txt
    ##clipboard.copy(output)

def wrMatrix(df):
    buff = StringIO.StringIO()
    df.to_csv(buff,header=False, index=False)
    buff.seek(0)
    output = buff.getvalue()
    txt = str(output)
    buff.close()
    return txt
    ##clipboard.copy(output)
