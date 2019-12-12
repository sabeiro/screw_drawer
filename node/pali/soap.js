UTIL = require('util')
var request = require('request')
var JSON = require("JSON");

fs = require('fs')
var log = (obj, msg) => {
    msg = msg || ""
    console.log(msg + UTIL.inspect(obj))
}

var xml2js = require('xml2js');
var parser = xml2js.Parser();
//request.log.setActionStart(request.requestID, "FINPT-WEBSERVICE", "webservice");
var newUrl = 'http://osb11g.mediaset.it:8021/PalinsestiOSB/PS/PS_MHPService?getMHPData';
var method = 'POST'
var headers = {"Accept":"application/json","Content-type":"application/json","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"};

var params = fs.readFileSync('paliReq.wsdl', 'utf8')

var  headers = {"Accept": "text/xml","Content-length": params.length,"Content-Type": "text/xml;charset=UTF-8","SOAPAction": "http://rti.mediaset.it/onair/main/MHPService","Connection":"close"};

var options = {
    url: newUrl,
    headers: headers,
    method: method,
    body: params
}

resp = request.post(options,function(error, data, response, body) {
    if (error == null ) {
	var txt = response.toString()
	// fs.writeFileSync("resp.xml",txt, function(err) {
	//     if(err) {return log(err);}
	//     log("The file was saved!");
	// });
	// console.log(txt)
	//log(response)
	//log(data)
	resp = parser.parseString(txt,function(err,data){
	    var jStr = JSON.stringify(data,null,4)
	    console.log(jStr);
	    return jStr;
	})
	//console.log(resp);
	return (resp)
    } else{}//
})



// parser.parseString(resp, function (err, data) {
//     log(data);
// });



// fs.writeFileSync("resp.xml",resp, function(err) {
//     if(err) {return log(err);}
//     log("The file was saved!");
// }); 


// var options = {
//     hostname: "http://osb11g.mediaset.it",
//     port: 8021,
//     path: "/PalinsestiOSB/PS/PS_MHPService?getMHPData",
//     method: "POST",
//     pfx: fs.readFileSync('keys.pfx'),
//     cert: fs.readFileSync('keys.cer'),
//     passphrase: "",
//     agent: false,
//     rejectUnauthorized: false,
//     secureProtocol: 'SSLv3_method',
// };

// //options.agent = new https.Agent(options);
// var reqFinWebs = https.request(options, function(resFinWebs) {
//     console.log(resFinWebs.statusCode);
//     if(resFinWebs.statusCode==200){}
// });
// reqFinWebs.end(soapXML);
// console.log(soapXML);


			       
