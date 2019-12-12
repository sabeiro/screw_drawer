query = {"token":token,
         "request":{"id":"OrderId","filters":[[{"op":"=","v":[29516,28410]}]],}
}
query = {"token":token,
    "request":{"status":1},
    "pagination":{"rowNumber":20,"page":1}
}
# r = requests.post(baseUrl+flightUrl,headers=headers,data=json.dumps(query))
# print(r.status_code, r.reason)
# r = requests.post(baseUrl+flightUrl,data=json.dumps(query))
# print(r.status_code, r.reason)
query = {
   "token":token,
    "request":{
	"reportId":"MD",
	"fields":[{
	    "id":"MD","sortp":2,"sortd":"desc","filters":[[{"op":"=","v":[29516,28410]},]]}]}
}
query = {"token":token,
    "dimensions":["AdvertiserType,Data,Publisher,Site,Section,Size,FlightDescription"],
    "filtering":{ "filtering" :[{"filterId":"17522","filterType":"publisher","filterCondition":"WEBTV[17522]"},{"filterId":"1","filterType":"size","filterCondition":"SPOT"}]},
    "_search":False,
    "nd":1478616510168,"rows":20,"page":1,"sidx":"","sord":"asc","totalrows":7
}
query = {
    "token":token
    ,"request":{
	"fields":[{
            "templateId":1086
            ,"startDate":"23/01/2017"
            ,"endDate":"29/01/2017"
            ,"dateFilterCombo":"select"
            ,"filter.projectionColumns":"advertiserType"
            ,"filter.projectionColumns":"data"
            ,"filter.projectionColumns":"publisher"
            ,"filter.projectionColumns":"site"
            ,"filter.projectionColumns":"section"
            ,"filter.projectionColumns":"size"
            ,"filter.projectionColumns":"flightdescription"
            ,"filtering":{ "filtering" :[{"filterId":"17522","filterType":"publisher","filterCondition":"WEBTV[17522]"},{"filterId":"1","filterType":"size","filterCondition":"SPOT"}]}
            ,"dimensions":"AdvertiserType,Data,Publisher,Site,Section,Size,FlightDescription"
        }]
    }
}
query = {
    "token":token
    ,"request":{
        "reportId":"MD",
 	"fields":[{
            "templateId":1086
            ,"startDate":"23/01/2017"
            ,"endDate":"29/01/2017"
            ,"filter.projectionColumns":"advertiserType"
            ,"filter.projectionColumns":"data"
            ,"filtering":{"filtering":[]}
            ,"dimensions":"AdvertiserType,Data"
        }]
    }
}


