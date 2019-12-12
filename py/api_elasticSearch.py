from elasticsearch import Elasticsearch
import json

key_file = os.environ['LAV_MEDIA'] + '/credenza/intertino.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)
cred = cred['elastic']

esclient = Elasticsearch([cred['host']])
queryS = {
    "query": {"match": {"message": "myProduct"}
    },
    "aggs": {"top_10_states": {
            "terms": {"field": "state","size": 10}
        }
    }
}

response = esclient.search(index='social-*',body=queryS)

curl -XGET 'localhost:9200/_cat/health?v&pretty'
curl -XGET 'localhost:9200/_cat/nodes?v'
curl -XGET 'localhost:9200/_cat/indices?v'
curl -XPUT 'localhost:9200/customer?pretty&pretty'
curl -XGET 'localhost:9200/_cat/indices?v&pretty'
curl -XPUT 'localhost:9200/customer/external/1?pretty&pretty' -H 'Content-Type: application/json' -d'{"name": "John Doe"}'
curl -XGET 'localhost:9200/customer/external/1?pretty&pretty'
curl -XDELETE 'localhost:9200/customer?pretty&pretty'
curl -XGET 'localhost:9200/_cat/indices?v&pretty'
curl -XPUT 'localhost:9200/customer?pretty'
curl -XPUT 'localhost:9200/customer/external/1?pretty' -H 'Content-Type: application/json' -d'{"name": "John Doe"}'
curl -XGET 'localhost:9200/customer/external/1?pretty'
curl -XDELETE 'localhost:9200/customer?pretty'
curl -XPUT 'localhost:9200/customer/external/1?pretty&pretty' -H 'Content-Type: application/json' -d'{"name": "John Doe"}'
curl -XPUT 'localhost:9200/customer/external/1?pretty&pretty' -H 'Content-Type: application/json' -d'{"name": "Jane Doe"}'
curl -XPUT 'localhost:9200/customer/external/2?pretty&pretty' -H 'Content-Type: application/json' -d'{"name": "Jane Doe"}'
curl -XPOST 'localhost:9200/customer/external/1/_update?pretty&pretty' -H 'Content-Type: application/json' -d'{"doc": { "name": "Jane Doe" }}'
curl -XPOST 'localhost:9200/customer/external/1/_update?pretty&pretty' -H 'Content-Type: application/json' -d'{"script" : "ctx._source.age += 5"}'
curl -XDELETE 'localhost:9200/customer/external/2?pretty&pretty'
curl -XPOST 'localhost:9200/customer/external/_bulk?pretty&pretty' -H 'Content-Type: application/json' -d'{"index":{"_id":"1"}}{"name": "John Doe" }{"index":{"_id":"2"}}{"name": "Jane Doe" }'
curl -XPOST 'localhost:9200/customer/external/_bulk?pretty&pretty' -H 'Content-Type: application/json' -d'{"update":{"_id":"1"}}{"doc": { "name": "John Doe becomes Jane Doe" } }{"delete":{"_id":"2"}}'
wget 'https://raw.githubusercontent.com/elastic/elasticsearch/master/docs/src/test/resources/accounts.json'
curl -H "Content-Type: application/json" -XPOST 'localhost:9200/bank/account/_bulk?pretty&refresh' --data-binary "@accounts.json"
curl 'localhost:9200/_cat/indices?v'
curl -XGET 'localhost:9200/bank/_search?q=*&sort=account_number:asc&pretty&pretty'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"query": { "match_all": {} },"sort": [{ "account_number": "asc" }]}'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"query": { "match_all": {} }}'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"query": { "match_all": {} },"size": 1}'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"query": { "match_all": {} },"from": 10,"size": 10}'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"query": { "match_all": {} },"sort": { "balance": { "order": "desc" } }}'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"query": { "match_all": {} },"_source": ["account_number", "balance"]}'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"query": { "match": { "account_number": 20 } }}'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"query": { "match": { "address": "mill" } }}'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"query": { "match": { "address": "mill lane" } }}'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"query": { "match_phrase": { "address": "mill lane" } }}'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"query":{"bool": {"must": [{ "match": { "address": "mill" } },{ "match": { "address": "lane" } }]}}}'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"query": {"bool": {"must": [{ "match": { "age": "40" } }],"must_not": [{ "match": { "state": "ID" } }]}}}'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"query": {"bool": {"must": { "match_all": {} },"filter": {"range": {"balance": {"gte": 20000,"lte": 30000}}}}}}'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"size": 0,"aggs": {"group_by_state": {"terms": {"field": "state.keyword"}}}}'
#SELECT state, COUNT(*) FROM bank GROUP BY state ORDER BY COUNT(*) DESC
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"size": 0,"aggs": {"group_by_state": {"terms": {"field": "state.keyword"},"aggs": {"average_balance": {"avg": {"field": "balance"}}}}}}'
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'{"size": 0,"aggs": {"group_by_state": {"terms": {"field": "state.keyword","order": {"average_balance": "desc"}},"aggs": {"average_balance": {"avg": {"field": "balance"}}}}}}'




##kibana
wget 'https://download.elastic.co/demos/kibana/gettingstarted/shakespeare.json'
wget 'https://download.elastic.co/demos/kibana/gettingstarted/accounts.zip'
gunzip accounts.zip
curl -H 'Content-Type: application/json' -XPUT http://localhost:9200/shakespeare -d '{"mappings" : {"_default_" : {"properties" : {"speaker" : {"type": "string", "index" : "not_analyzed" },"play_name" : {"type": "string", "index" : "not_analyzed" },"line_id" : { "type" : "integer" },"speech_number" : { "type" : "integer" }}}}}';
curl -H 'Content-Type: application/json' -XPUT http://localhost:9200/logstash-2015.05.18 -d '{ "mappings": {"log": {"properties": {"geo": {"properties": {"coordinates": {"type": "geo_point"}}}}}}}';
curl -H 'Content-Type: application/json' -XPUT http://localhost:9200/logstash-2015.05.19 -d '{"mappings": {"log": {"properties": {"geo": {"properties": {"coordinates": {"type": "geo_point"}}}}}}}';
curl -H 'Content-Type: application/json' -XPUT http://localhost:9200/logstash-2015.05.20 -d '{"mappings": {"log": {"properties": {"geo": {"properties": {"coordinates": {"type": "geo_point"}}}}}}}';
curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/bank/account/_bulk?pretty' --data-binary @accounts.json
curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/shakespeare/_bulk?pretty' --data-binary @shakespeare.json
wget 'https://download.elastic.co/demos/kibana/gettingstarted/logs.jsonl.gz'
curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/_bulk?pretty' --data-binary @logs.jsonl
curl 'localhost:9200/_cat/indices?v'


curl -XPUT -u elastic 'localhost:9200/_xpack/security/user/elastic/_password' -H "Content-Type: application/json" -d '{
  "password" : "changeme"
}'

curl -XPUT -u elastic 'localhost:9200/_xpack/security/user/kibana/_password' -H "Content-Type: application/json" -d '{
  "password" : "changeme"
}'

curl -XPUT -u elastic 'localhost:9200/_xpack/security/user/logstash_system/_password' -H "Content-Type: application/json" -d '{
  "password" : "changeme"
}'



curl -XPOST -u elastic 'localhost:9200/_xpack/security/role/events_admin' -H "Content-Type: application/json" -d '{
  "indices" : [
    {
      "names" : [ "events*" ],
      "privileges" : [ "all" ]
    },
    {
      "names" : [ ".kibana*" ],
      "privileges" : [ "manage", "read", "index" ]
    }
  ]
}'

curl -XPOST -u elastic 'localhost:9200/_xpack/security/role/events_admin' -H "Content-Type: application/json" -d '{
  "indices" : [
    {
      "names" : [ "events*" ],
      "privileges" : [ "all" ]
    },
    {
      "names" : [ ".kibana*" ],
      "privileges" : [ "manage", "read", "index" ]
    }
  ]
}'

curl -XPOST -u elastic 'localhost:9200/_xpack/security/user/johndoe' -H "Content-Type: application/json" -d '{
  "password" : "userpassword",
  "full_name" : "John Doe",
  "email" : "john.doe@anony.mous",
  "roles" : [ "events_admin" ]
}'
