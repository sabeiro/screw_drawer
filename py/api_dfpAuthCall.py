import json
import os
import argparse
import sys
from oauth2client import client
from googleads import dfp
from googleads import oauth2

from oauth2client.service_account import ServiceAccountCredentials
key_file2 = os.environ['LAV_DIR'] + '/credenza/dfp-intertino.json'
cred2 = []
with open(key_file2) as f:
    cred2 = json.load(f)

scopes = cred2['scopes']
credentials = ServiceAccountCredentials.from_json_keyfile_name(os.environ['LAV_DIR'] + '/credenza/dfp-intertino-861da83250a9.json',scopes=scopes)
#credentials = ServiceAccountCredentials.from_json_keyfile_name('/home/sabeiro/lav/media/credenza/dfp-intertino.json',scopes=scopes)
delegated_credentials = credentials.create_delegated('anticolo@intertino-145408.iam.gserviceaccount.com')
from httplib2 import Http
http_auth = credentials.authorize(Http())
from apiclient.discovery import build
sqladmin = build('sqladmin','v1beta3',http=http_auth)
response = sqladmin.instances().list(project='intertino-145408').execute()


# from oauth2client.contrib.appengine import AppAssertionCredentials
# credentials = AppAssertionCredentials('https://www.googleapis.com/auth/sqlservice.admin')
