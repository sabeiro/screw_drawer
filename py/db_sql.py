import os
import sys
import random
import numpy as np
import scipy as sp
import pandas as pd
import json
import MySQLdb
from pandas.io import sql
import sqlalchemy

def open_conn():
    key_file = os.environ['LAV_DIR'] + '/credenza/intertino.json'
    cred = []
    with open(key_file) as f:
        cred = json.load(f)
    cred = cred['mysql']['intertino']
    engine = sqlalchemy.create_engine('mysql://'+cred['user']+':'+cred['pass']+'@'+cred['host']+'/'+cred['db'],echo=False)
    conn = engine.connect()
    return conn

# def close_conn():
#     conn.close()


def csv_from_excel(primeUrl):
    req = urllib2.Request(primeUrl)
    response = urllib2.urlopen(req)
    excel = response.read()
    out_file = open("test.xls","w")
    out_file.write(excel)
    out_file.close()
    workbook = xlrd.open_workbook("test.xls")
    all_worksheets = workbook.sheet_names()
    for worksheet_name in all_worksheets:
        worksheet = workbook.sheet_by_name(worksheet_name)
        your_csv_file = open(''.join([worksheet_name,'.csv']), 'wb')
        wr = csv.writer(your_csv_file, quoting=csv.QUOTE_ALL)

        for rownum in xrange(worksheet.nrows):
            wr.writerow([unicode(entry).encode("utf-8") for entry in worksheet.row_values(rownum)])
        your_csv_file.close()

        
        



