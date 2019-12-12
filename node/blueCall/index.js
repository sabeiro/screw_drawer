//http://tags.bluekai.com/site/30931?ret=js
//http://tags.bluekai.com/site/32157
//https://devportal.bluekai.com/
var
UTIL = require('util')
URL = require('url-parse')
CRYPTO = require('crypto')
FS = require('fs')
REQUEST = require('request')
CHEERIO = require('cheerio')
SEQUENCE = require('sequence').Sequence
RESTIFY = require('restify')
SOCKETIO = require('socket.io')
CHECKURL = require('valid-url')
UTF8 = require('utf8')
_consoleLog = console.log

var request = require('request');
FileCookieStore = require('tough-cookie-filestore');
j = request.jar(new FileCookieStore('cookies.json'));
request = request.defaults({ jar : j })
testIndex = 1
testLoop = 1000

// GLOBAL PREFERENCES
var headers = {"Accept":"application/json","Content-type":"application/json","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"};
var api_base_url = "http://services.bluekai.com/Services/WS/";

var api_bluekai_sect = ["sites","classificationRules","Taxonomy","audiences","classificationCategories","Order","Vertical"];

var name = 'RTI DMP Mediamond JSON Mediamond ',
    uid='750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f',
    secretkey= '0e3cb02cacfcca23724e25515b4cbe61b2ac954dc0fc495d1daadd246eddd0c5',
    BK_site_ID= [], //29139,29140,30579,30580,30099,30100,30581,30582,29137,29138,28415,28416
    BK_partner_ID= 3256;

//require('./config/app_config.js')

var signatureInputBuilder = (url, method, data) => {
    var stringToSign = method
    var parsedUrl = new URL(url)
    stringToSign += parsedUrl.pathname
    var qP = parsedUrl.query.split('&')
    if(qP.length > 0){
     	for(qs=0;qs<qP.length;qs++){
     	    var qS = qP[qs]
     	    var qP2 = qS.split('=')
            if (qP2.length > 1)
                stringToSign += qP2[1]
     	}
    }
    if(data != null && data.length > 0)
     	stringToSign += data
    log(stringToSign);
    var s = CRYPTO.createHmac('sha256',secretkey).update(stringToSign).digest('base64')
    //var s = CRYPTO.createHmac('sha256', bksecretkey).update(new Buffer(stringToSign, 'utf-8')).digest('base64')
    u = encodeURIComponent(s)
    var newUrl = url
    if(url.indexOf('?') == -1 )
        newUrl += '?'
    else
        newUrl += '&'
    newUrl += 'bkuid=' + uid + '&bksig=' + u
    return newUrl
}
var doRequest = (url, method, data) => {
    var newUrl = signatureInputBuilder(url,method,data)
    log('url:  ' + newUrl);
    var options = {
  	url: newUrl,
  	headers: headers,
  	method: method,
  	body: data
    }
    if(method === "POST"){
	REQUEST.post(options, function(error, data, response, body) {
	    if (error == null ) {
		//log(response)
		return (response)
	    } else{}//
	})
    }
    if(method === "GET"){
	REQUEST.get(options, function(error, response, body) {
	    if (error == null  && !error && response.statusCode == 200) {
		//log(body);
		FS.writeFile("/Users/giovanni.marelli.PUBMI2/lav/media/node/json/audiences.json",body, function(err) {
		    if(err) {return console.log(err);}
		    console.log("The file was saved!");
		});
		return (body)
	    } else{}
	})
    }
    if(method === "PUT"){
	REQUEST.put(options, function(error, data, response, body) {
	    if (error == null  && !error && response.statusCode == 200) {
		//log(body);
		return (body)
	    } else{response}
	})
    }
}
var log = (obj, msg) => {
    msg = msg || ""
    //console.log(msg + UTIL.inspect(obj, false, null))
    console.log(msg + UTIL.inspect(obj))
}

requestJSONReturn = (loopIndex) =>{
    if(loopIndex >= testLoop)
	return
    request('http://tags.bluekai.com/site/30931?ret=js',function(error,response,body){
	if (!error && response.statusCode == 200) {
	    //console.log(body) // Show the HTML for the Google homepage.
	    body = body.replace('var bk_results = ','')
	    body = body.substring(0, body.length-2)
	    //console.log(body)
	    body = JSON.parse(body)
	    campaigns = ''
	    for(i in body.campaigns){
	    	campaigns += body.campaigns[i].campaign + ' '
	    }
	    console.log("TEST #" + loopIndex + " :: " + campaigns)
	    requestJSONReturn(++loopIndex)
	}
    })
}

data = {};
body = doRequest(api_base_url + "audiences","GET",JSON.stringify(data));
log(body)

//requestJSONReturn(0);
