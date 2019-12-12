import api_dotLib as dot
import numpy as np
import pandas as pd
import clipboard
import re
import StringIO

token = dot.getToken()
dataQ = ["2017-01-30","2017-02-05"]
headers = {"Column-Names":"Date|FlightDescription|FlightID|Imps"}
##tappi
query = {"token":token
         ,"request":{"id":"OrderId","filters":[[{"op":"=","v":[29516,28410]}]],}
}
query = {"token":token
         ,"request":{"status":1}
         ,"pagination":{"rowNumber":20,"page":1}
}
query = {"token":token
         ,"request":{"id":"description","filters":[[{"op":"CONTAINS","v":["DATA PLANNING"]}]],}
         ,"pagination":{"rowNumber":20,"page":1}
}
dataP = dot.flightList(query,headers)
print dataP
query = {"token":token,
         "request":{"id":"osi","filters":[[{"op":"<=","v":[-20]}]],}
         ,"pagination":{"rowNumber":20,"page":1}
}
under = dot.flightList(query,headers)
print under


