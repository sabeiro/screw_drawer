import os
import cgi

form = cgi.FieldStorage()
callback = form.getvalue('callback','')

address = cgi.escape(os.environ["REMOTE_ADDR"])

json = '{"ip": "'+address+'", "address":"'+address+'"}'

#Allow cross domain XHR
print 'Access-Control-Allow-Origin: *'
print 'Access-Control-Allow-Methods: GET'

if callback != '':
  print 'Content-Type: application/javascript'
  result = callback+'('+json+');'
else:
  print 'Content-Type: application/json'
  result = json

print ''
print result
