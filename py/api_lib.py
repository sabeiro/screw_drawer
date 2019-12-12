def printCurl(url,method,headers,data):
    txt = 'curl ' + url + ' -X ' + method + " -H \'" + json.dumps(headers) + "\' -d \'" + json.dumps(query) + "\'"
    return txt
