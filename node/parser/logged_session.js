var parser = require("htmlparser2");
var request = require('request');
var sys = require('util');
var fs = require('fs');
var cheerio = require('cheerio');
var cred = JSON.parse(fs.readFileSync('/home/sabeiro/lav/media/credenza/intertino.json', 'utf8'));
var cred2 = JSON.parse(fs.readFileSync('/home/sabeiro/lav/media/credenza/dotandmedia.json', 'utf8'));
var sqlUsr = cred.mysql.intertino
var mysql = require('mysql')
var async = require('async');
var connection = mysql.createConnection({host:sqlUsr.host,user:sqlUsr.user,password :sqlUsr.pass,database :sqlUsr.db});
var baseUrl = 'http://dashboard.ad.dotandad.com/'
var headerD = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
var headerD = {"Accept":"application/json","Content-type":"application/json","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
function log(txt){
    console.log(txt);
}
FileCookieStore = require('tough-cookie-filestore');
jar = request.jar(new FileCookieStore('./dot_session.json'));
testIndex = 1
testLoop = 1000
//var source = fs.createReadStream('./dot_session.json');

function callbackList(headerA){
    headerD['Cookie'] = JSON.stringify(headerA);
    log(headerD);
    request({url:'http://dashboard.ad.dotandad.com/subflightList.action'
	     ,headers:headerD
	     ,jar:jar
	     ,method: 'GET'}
	    ,function(error,response,body){
		log(response);
		return body;
	    });
}

function flightList(cookieF){
    var j = request.jar(new FileCookieStore('./dot_session.json'));
    var sesCookie = JSON.parse(fs.readFileSync(cookieF, 'utf8'));
    var setcookie = sesCookie["Set-Cookie"];
//    var cookieS = cookie.parse('com.dotandmedia.entities.ReportFilter.last_order_by=filterType asc;com.dotandmedia.entities.Subflights.last_order_by=startTs desc')
    //;com.dotandmedia.entities.NodesGroups.last_order_by="description asc";com.dotandmedia.entities.Nodes.last_order_by="description asc";com.dotandmedia.entities.SubflightAds.last_order_by="id_ad_adRefCode asc";com.dotandmedia.entities.SubflightTargetings.last_order_by="keyword_code asc";com.dotandmedia.entities.SubflightComment.last_order_by="createdOn asc";com.dotandmedia.web.model.FullReport.last_order_by="creationTime asc";"com.dotandmedia.entities.ExternalDMP.last_order_by="description desc";com.dotandmedia.entities.SubflightList.last_order_by="absoluteEndTs desc";com.dotandmedia.entities.SubflightList.impsDistributionDescription=-1;com.dotandmedia.entities.SubflightList.description="data planning"')
    
    log(setcookie)
    headerD['Cookie'] = [sesCookie["Set-Cookie"]];
    //headerD = sesCookie;
    log(headerD);
    //request = request.defaults({ jar : j })
    request({url:'http://dashboard.ad.dotandad.com/subflightList.action'
	     ,headers:headerD
	     //,jar:j
	     ,method: 'GET'}
	    ,function(error,response,body){
		var $ = cheerio.load(body);
		var tabTxt = $('.ui-jqgrid-bdiv').html();
		log(response.body);
		return body;
	    });
}

function auth(url,cred2,callback){
    request({
	uri:url
	,method:"POST"
	,form:{name:cred2['username'],password:cred2['password']}
    }
	    ,function(error,response,body){
		if(error){
		    log(error)
		    return;
		}else{
		    log(response.headers)
		    //return callback(response.headers);
		    return callback(response.headers);
		}
	    });
}

// async.parallel([
//     function(callback){
// 	request({url:'http://dashboard.ad.dotandad.com/subflightList.action'}
// 		,function(error,response,body){callback();})
//     }
//     ,function(callback){
// 	request({url:'http://dashboard.ad.dotandad.com/subflightList.action'}
// 		,function(error,response,body){callback();})
//     }
//     ,function(error){log(error)}
// ]);

requestJSONReturn = (loopIndex) =>{
    if(loopIndex >= testLoop)
	return
    // request.get(baseUrl + 'login.action',{'auth':{'user':cred2['username'],'pass':cred2['password'],'sendImmediately': false}});
    // request.get(baseUrl+'login.action').auth(cred2['username'],cred2['password'], false);
    //auth(baseUrl+'login.action',cred2,callbackList);
    flightList("./dot_session.json");
}

requestJSONReturn(0);

// curl -d "username=giovanni.marelli@mediamond.it&password=dotWa3tpo&submit=Login" --dump-header headers http://dashboard.ad.dotandad.com/login.action
// curl -L -b headers http://dashboard.ad.dotandad.com/subflightList.action

// curl -d "username=mediamond@pubmatic.com&password=PubmaticMediaMond123&submit=Login" --dump-header headers https://apps.pubmatic.com/publisher/
// curl -L -b headers https://apps.pubmatic.com/dashboard/app/#/publisher
// curl -L -b headers https://apps.pubmatic.com/publisher/?viewName=dealManagement

