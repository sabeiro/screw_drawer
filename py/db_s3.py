from boto.s3.connection import S3Connection
from boto.s3.key import Key
import boto
import json
import boto3
import argparse
#from pyspark import SparkContext, SparkConf
from boto.s3.connection import S3Connection
#import parquet

cred = {}
with open(os.environ['LAV_DIR']+"/credenza/aws_env.json") as f:
    cred = json.load(f)
cred = cred['rti']

conn = boto.connect_s3(cred['AWS_ACCESS_KEY_ID'],cred['AWS_SECRET_ACCESS_KEY'])#,cred['AWS_DEFAULT_REGION'])
bucket = conn.get_bucket(cred['bucketN'])
folders = bucket.list("","/")
for folder in folders:
    print folder.name

s3 = boto3.resource('s3')
for bucket in s3.buckets.all():
    print(bucket.name)

    
for folder in list(bucket.list("dl_rti/dl_bk_user_synthesis_ls/date=20170430/", "")):
    print folder.name

bucket_entries = bucket.list(prefix='dl_rti/dl_bk_user_synthesis_ls/date=20170430/')
for entry in bucket_entries:
    print entry


conn = S3Connection(args.aws_access_key_id, args.aws_secret_access_key)
bucket = conn.get_bucket(args.bucket_name)
keys = bucket.list()
def map_func(key)
    # Use the key to read in the file contents, split on line endings
    for line in key.get_contents_as_string().splitlines():
        # parse one line of json
        j = json.loads(line)
        if "user_id" in j && "event" in j:
            if j['event'] == "event_we_care_about":
                yield j['user_id'], j['event']




    
#k = Key(bucket,fileUrl)
#k.get_contents_to_filename(os.environ['LAV_DIR']+"/tmp/s3.txt")

folders = bucket.list("","/")
for folder in folders:
    print folder.name

s3 = boto3.resource('s3')
for bucket in s3.buckets.all():
    print(bucket.name)

bucket = s3.Bucket(name=bucketN)
print bucket
for obj in bucket.objects.all():
    key = obj.key
    body = obj.get()['Body'].read()



objs = boto3.client.list_objects(Bucket=bucketN)
while 'Contents' in objs.keys():
    objs_contents = objs['Contents']
    for i in range(len(objs_contents)):
        filename = objs_contents[i]['Key']



s3 = boto3.client('s3', region_name=cred['AWS_DEFAULT_REGION'])
s3.put_object(Bucket=datasetF, Key=self.name, Body=self.value)


conn = boto.connect_s3(cred['AWS_DEFAULT_REGION'])
bucket = conn.get_bucket(datasetF)

for line in smart_open.smart_open('s3://mybucket/mykey.txt'):
    print line

bucket = conn.get_bucket(baseUrl + folderUrl + fileUrl)
k = Key(bucket)
k.key = 'filename.txt'
k.open()
k.read(10)


peopleDF = spark.read.json("examples/src/main/resources/people.json")

# DataFrames can be saved as Parquet files, maintaining the schema information.
peopleDF.write.parquet("people.parquet")

# Read in the Parquet file created above.
# Parquet files are self-describing so the schema is preserved.
# The result of loading a parquet file is also a DataFrame.
parquetFile = spark.read.parquet("people.parquet")

# Parquet files can also be used to create a temporary view and then used in SQL statements.
parquetFile.createOrReplaceTempView("parquetFile")
teenagers = spark.sql("SELECT name FROM parquetFile WHERE age >= 13 AND age <= 19")
teenagers.show()
# +------+
# |  name|
# +------+
# |Justin|
# +------+



## assuming parquet file with two rows and three columns:
## foo bar baz
## 1   2   3
## 4   5   6

df = spark.read.parquet("infile.parquet")
df.write.csv("outfile.csv")


with open("test.parquet") as fo:
   # prints:
   # {"foo": 1, "bar": 2}
   # {"foo": 4, "bar":1 5}
   for row in parquet.DictReader(fo, columns=['foo', 'bar']):
       print(json.dumps(row))


with open("test.parquet") as fo:
   # prints:
   # 1,2
   # 4,5
   for row in parquet.reader(fo, columns=['foo', 'bar']):
       print(",".join([str(r) for r in row]))





myfile = opener.open(baseUrl)
k = Key(b)
k.key = 'yourfile'
k.set_contents_from_filename('yourfile.txt')




# # Get a Spark context and use it to parallelize the keys
# conf = SparkConf().setAppName("MyFileProcessingApp")
# sc = SparkContext(conf=conf)
# pkeys = sc.parallelize(keys)
# # Call the map step to handle reading in the file contents
# activation = pkeys.flatMap(map_func)
# # Additional map or reduce steps go here...

# Upload a new file
# data = open('test.jpg', 'rb')
# s3.Bucket('my-bucket').put_object(Key='test.jpg', Body=data)

# Get the service resource
#sqs = boto3.resource('sqs')

# Create the queue. This returns an SQS.Queue instance
#queue = sqs.create_queue(QueueName='test', Attributes={'DelaySeconds': '5'})

# You can now access identifiers and attributes
#print(queue.url)
#print(queue.attributes.get('DelaySeconds'))

