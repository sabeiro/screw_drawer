import json
key_file = os.environ['LAV_DIR'] + '/credenza/intertino.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)
cred = cred['hive']



"create external table "+cred['db']+".dl_bk_user_profile_change_history(
 gigya_id string,
 att_type string,
 att_value string,
 ini_ts string,
 end_ts string
) 
stored as parquet
location" cred['bucket1'] + 's3a://dl-bluekai-prod/dl_rti/dl_bk_user_profile_change_history/date=YYYYMMDD/;'
