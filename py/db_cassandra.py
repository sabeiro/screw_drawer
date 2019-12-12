from cassandra.cluster import Cluster
import json
key_file = os.environ['LAV_DIR'] + '/credenza/intertino.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)
cred = cred['cassandra']
cluster = Cluster([cred['ip']],port=9042)
session = cluster.connect(cred['keyspace'])
##"Create keyspace "+cred['keyspace']+" with replicaton={'class':strategy name,'replication_factor': No of replications on different nodes}"

#session.set_keyspace('users')
rows = session.execute('SELECT name, age, email FROM users')
for user_row in rows:
    print user_row.name, user_row.age, user_row.email


    
session.execute("""insert into users (lastname, age, city, email, firstname) values ('Jones', 35, 'Austin', 'bob@example.com', 'Bob')""")
result = session.execute("select * from users where lastname='Jones' ")[0]
print result.firstname, result.age
session.execute(
    """
    INSERT INTO users (name, credits, user_id, username)
    VALUES (%(name)s, %(credits)s, %(user_id)s, %(name)s)
    """,
    {'name': "John O'Reilly", 'credits': 42, 'user_id': uuid.uuid1()}
)
