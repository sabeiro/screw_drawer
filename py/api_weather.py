import urllib2, urllib
import json,gzip,zlib,sys,csv

baseurl = "https://query.yahooapis.com/v1/public/yql?"
yql_query = "select * from weather.forecast where woeid=12845032" ##Salò
yql_query = "select * from weather.forecast where woeid=718345" ##Milano
yql_query = "select * from weather.forecast where woeid=721943"
##yql_query = 'select * from weather.forecast where woeid in (select woeid from geo.places(1) where text="nome, ak")'
yql_url = baseurl + urllib.urlencode({'q':yql_query}) + "&format=json"
result = urllib2.urlopen(yql_url).read()
data = json.loads(result)
print data['query']['results']

result = urllib2.urlopen("http://api.openweathermap.org/data/2.5/weather?q=London,uk")
result = urllib2.urlopen("http://api.openweathermap.org/data/2.5/weather?lat=35&lon=139&cnt=10")##zip
fo = open("../../raw/city.list.json.gz","r")
fo = gzip.open("../../raw/city.list.json.gz","rb")


##https://www.wunderground.com/history/airport/LIMC/2017/1/1/DailyHistory.html?req_city=Milan&req_state=LM&req_statename=Italy&reqdb.zip=00000&reqdb.magic=1&reqdb.wmo=16066
https://secure.adnxs.com/jpt?&id=7518967&size=728x90&referrer=https%3A%2F%2Fwww.wunderground.com%2Fhistory%2Fairport%2FLIMC%2F2017%2F1%2F1%2FDailyHistory.html%3Freq_city%3DMilan%26req_state%3DLM%26req_statename%3DItaly%26reqdb.zip%3D00000%26reqdb.magic%3D1%26reqdb.wmo%3D16066&callback=callback&callback_uid=wx_hsd&psa=0

##result = urllib2.urlopen("http://www.wunderground.com/cgi-bin/findweather/getForecast?code=LIMC&airportorwmo=airport&historytype=DailyHistory&search_city=Milan&search_state=LM&search_statename=Italy&search_zip=00000&search_magic=1&search_wmo=16066&month=1&day=1&year=2017")
##result = urllib2.urlopen("https://www.wunderground.com/history/airport/LIMC/2017/1/1/DailyHistory.html?req_city=Milan&req_state=LM&req_statename=Italy&reqdb.zip=00000&reqdb.magic=1&reqdb.wmo=16066")
