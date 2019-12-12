import imaplib
import poplib
import re
import email
import email.header
import sys
import string
import os
import json
import datetime
from openpyxl import Workbook, load_workbook
import pandas as pd
import numpy as np
import zipfile
import xlrd
os.chdir('/tmp/')

def cleanDf(df):
    df = df.dropna(how="all")
    if (sum(df.columns == None) == len(df.columns)):
        df.columns = df.iloc[0]
        df = df.drop(df.index[0])
    return df

def parse_xlsx(filename,sheetname):
    open(filename,'wb').write(part.get_payload(decode=True))
    wb = load_workbook(filename,data_only=True)
    ws = wb[sheetname]
    M = np.array([[x.value for x in y] for y in ws.rows])
    df = pd.DataFrame(M[1:],columns=M[0])
    return df

def parse_xls(filename,sheetname):
    xl = pd.ExcelFile(filename)
    df = xl.parse(sheetname)
    return df
    # book = xlrd.open_workbook(filename) # print number of sheets
    # first_sheet = book.sheet_by_name(sheetname) # read a row
    # df = pd.DataFrame([x for x in ])
    # for row_idx in range(0,first_sheet.nrows):    # Iterate through rows
    #     print first_sheet.row_values(row_idx) # read a cell

def pushElastic(df,indexN,date):
    headers = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
    baseUrl = 'http://localhost:9200/'
    sData = {"pretty":""}
    key_file = os.environ['LAV_DIR'] + '/credenza/intertino.json'
    cred = []
    with open(key_file) as f:
        cred = json.load(f)
        requests.delete(baseUrl+indexN+"?pretty",headers=headers,auth=(cred['elastic']['user'],cred['elastic']['pass']))
    resq = requests.get(baseUrl+'_cat/indices?v&pretty',headers=headers,auth=(cred['elastic']['user'],cred['elastic']['pass']))
    df['date'] = date
    for k in df.iterrows():
        print k
        
    #notA['Day'].fillna("6/1/17",inplace=True)
    notA['date'] = [datetime.datetime.strptime(x,"%m-%d-%Y") for x in notA['Day']]
    notA.fillna("",inplace=True)
    notA['Campaign'] = notA['Campaign'].apply(lambda x: re.sub("_"," ",x))
    notA['Targeted Audience Name'] = notA['Targeted Audience Name'].apply(lambda x: re.sub("_"," ",x))
    notA['Impressions'] = notA['Impressions'].apply(lambda x: int(re.sub(",","",x)) )
    notA['Clicks'] = notA['Clicks'].apply(lambda x: int(re.sub(",","",x)) )
    notA['Conversion'] = notA['Conversion'].apply(lambda x: int(x) )
    notA['Advertiser Spending Advertiser Currency'] = notA['Advertiser Spending Advertiser Currency'].apply(lambda x: float(re.sub(",","",x)) )
    notA['source'] = "rest"
    sectL = ['Banzai','Yahoo','Mediamond']
    for i in range(0,len(sectL)):
        idxA = notA['Targeted Audience Name'].str.contains(str(sectL[i]))
        notA['source'][idxA] = str(sectL[i])
    
    stopW = ['IT','Banzai',"Mediamond","Yahoo","Interest","Premium Audience"]
    notA['Targeted Audience Name'] = notA['Targeted Audience Name'].apply(lambda x: ' '.join(w for w in x.split() if w not in stopW))
    
    sucS = ""
    for i in range(0,len(notA)):
        idS = {"index":{"_index":int(datetime.datetime.strftime(notA.loc[i,'date'],"%Y%m%d")),"_type":"log"}}
        timest = list(str(notA.loc[i]['date']) + "Z")
        timest[10] = 'T'
        timest = "".join(timest)
        tS = "".join(timest)
        sData = {"@timestamp":tS,"client":notA.loc[i]['Advertiser'],"target":notA.loc[i]['Targeted Audience Name'],"source":notA.loc[i]['source'],"order":notA.loc[i]['Campaign Id'],'size':notA.loc[i]['Ad Size'],'rev':notA.loc[i]['Advertiser Spending Advertiser Currency'],"imps":notA.loc[i]['Impressions'],"click":notA.loc[i]['Clicks'],"conversion":notA.loc[i]['Conversion']}
        resq = requests.post(baseUrl+indexN+'/external/'+str(i)+"?pretty",headers=headers,data=json.dumps(sData),auth=(cred['elastic']['user'],cred['elastic']['pass']))
        if resq.status_code >= 400:
            print resq.json()
        sucS += " " + str(resq.status_code) #+ resq.text
        if i%20 == 0:
            print sucS
            sucS = ""

    
repL = ["adform","dotand","virgi"]
punctC = string.punctuation
key_file = os.environ['LAV_DIR'] + '/credenza/intertino.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)

if True:
    mailC = imaplib.IMAP4_SSL(cred['bot']['url'])
    # mailC = imaplib.IMAP4(cred['bot']['url'],993)
    mailC.login(cred['bot']['user'],cred['bot']['pass'])
    #print mailC.stat()
if False:
    mailC = poplib.POP3(cred['bot']['url'])
    #mailC = poplib.POP3_SSL(cred['bot']['url'])
    mailC.user(cred['bot']['user'])
    mailC.pass_(cred['bot']['pass'])

typ, data = mailC.select("INBOX")
typ, data = mailC.search(None, 'ALL')#UnSeen
num = data[0].split()[0]
fileL = []
for num in data[0].split():
    typ, dat = mailC.fetch(num,'(RFC822)')#"(BODY.PEEK[])")
    if typ != 'OK':
        print "ERROR getting message", num
        continue

    email_body = dat[0][1]
    decode = email.header.decode_header(msg['Subject'])[0]
    subject = unicode(decode[0])
    print 'Message %s: %s FROM %s' % (num, subject, msg['From'])
    print 'Raw Date:', msg['Date']
    msg = email.message_from_string(email_body)
    # if not any([msg['from'].find(x) > 0 for x in repL]):
    #     continue
    if msg.get_content_maintype() != 'multipart':
        continue
    for part in msg.walk():
        if part.get_content_maintype() == 'multipart':
            continue
        if part.get('Content-Disposition') is None:
            continue
        filename = part.get_filename()
        print "ATTACHMENT) " + filename
        if filename.find(".zip") > 0:
            archive = zipfile.ZipFile('/tmp/'+filename, 'r')
            filename = archive.extract(archive.namelist()[0])
        else :
            filename = '/tmp/' + filename
        sheetname = "video"
        if filename == "/tmp/Deal Performance.xlsx":
            sheetname = "Deal Performance"
        
        if filename.find(".xlsx") > 0:
            df = parse_xlsx(filename,sheetname)
        elif filename.find(".xls") > 0:
            df = parse_xls(filename,sheetname)
        elif filename.find(".csv") > 0:
            df = pd.read_csv(filename)
        df = cleanDf(df)
        



mailC.close()
mailC.logout()

