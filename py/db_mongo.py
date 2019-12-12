import os
import sys
import random
import numpy as np
import scipy as sp
import pandas as pd
import json
from pymongo import MongoClient

def open_conn():
    key_file = os.environ['LAV_DIR'] + '/credenza/intertino.json'
    cred = []
    with open(key_file) as f:
        cred = json.load(f)
    cred = cred['mongo']
    client = MongoClient(cred['host'], 27017)
    db = client.test_database
    access_token_store = AuthCodeStore(collection=db["auth_codes"])
    access_token_store = AccessTokenStore(collection=db["access_tokens"])

    engine = sqlalchemy.create_engine('mysql://'+cred['user']+':'+cred['pass']+'@'+cred['host']+'/'+cred['db'],echo=False)
    conn = engine.connect()
    return conn

