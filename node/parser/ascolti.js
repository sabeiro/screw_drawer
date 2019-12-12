var parser = require("htmlparser2");
var request = require('request');
var sys = require('util');
var fs = require('fs');
var cheerio = require('cheerio');
var obj = JSON.parse(fs.readFileSync('/home/sabeiro/lav/media/credenza/intertino.json', 'utf8'));
var sqlUsr = obj.mysql.intertino
var mysql = require('mysql')
var connection = mysql.createConnection({host:sqlUsr.host,user:sqlUsr.user,password :sqlUsr.pass,database :sqlUsr.db});

//rss
//amflaff

var baseUrl = "http://www.mediaset.it/auditel/ascolti.shtml"
var headerD = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
var bodyReq = {}
var formD = {'field1':'data','field2':'data'}
var tabV = new parser.Parser({
    onopentag: function(name, attribs){if(name === "script" && attribs.type === "text/javascript"){console.log("JS! Hooray!");}},
    ontext: function(text){console.log("-->", text);},
    onclosetag: function(tagname){if(tagname === "script"){console.log("That's it?!");}}
}, {decodeEntities: true});

function log(txt){
    console.log(txt);
}
FileCookieStore = require('tough-cookie-filestore');
cookieF = process.env.LAV_DIR + '/src/node/parser/cookies.json';
j = request.jar(new FileCookieStore(cookieF));
request = request.defaults({ jar : j })
testIndex = 1
testLoop = 1000
var source = fs.createReadStream(cookieF);

function bridgeConsole(){
    var script = document.createElement('script');
    script.src = 'http://code.jquery.com/jquery-1.11.0.min.js';
    script.type = 'text/javascript';
    document.getElementsByTagName('head')[0].appendChild(script);
}
function zeroPad(num, places) {
  var zero = places - num.toString().length + 1;
  return Array(+(zero > 0 && zero)).join("0") + num;
}
function readIt(body){
    ///console.log(body) // Show the HTML for the Google homepage.
    // parser.parseComplete(body);
    // sys.puts(sys.inspect(handler.dom, false, null));
    // body = JSON.parse(body)
    var $ = cheerio.load(body);
    var tabTxt = $('table').html();
    //tabV.write(tabTxt);
    //tabV.end();
    var tabD = []
    $('tr').each(function(i,tr){
	var children = $(this).children();
	var it1 = children.eq(0);
	var row = [];
	for(var i=0;i<children.length;i++){
	    row.push(children.eq(i));
	}
	tabD.push(row);
    });
    var csvContent = "";
    var colN = [];
    for(var c=0;c<tabD[1].length;c++){
	colN.push(tabD[1][c].text().replace(/[.,\/#!$%\^&\*;:{}=\-_`~()]/g,""));
    }
    var sqlCont = "CREATE TABLE IF NOT EXISTS `inventory_tv_audience` (`date` date, `tot` double DEFAULT NULL, `fascia7` double DEFAULT NULL, `fascia9` double DEFAULT NULL, `fascia12` double DEFAULT NULL, `fascia15` double DEFAULT NULL, `fascia18` double DEFAULT NULL, `fascia20` double DEFAULT NULL, `fascia22` double DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1;";
    var sqlCont = "INSERT INTO `inventory_tv_audience` (`date`,`tot`,`fascia7`,`fascia9`,`fascia12`,`fascia15`,`fascia18`,`fascia20`,`fascia22`) VALUES "
    today = new Date();
    sqlCont += "('"+today.getFullYear()+'-'+zeroPad(today.getMonth()+1,2)+'-'+zeroPad(today.getDate(),2)+"',";
    for(var c=2;c<tabD[7].length;c++){
	sqlCont += tabD[7][c].text().replace(/[%\\.]/g,"") + '000,';
    }
    sqlCont = sqlCont.substring(0,sqlCont.length-1)
    sqlCont += ');';
    log(sqlCont);
    connection.connect()
    connection.query(sqlCont,function (err, rows, fields) {
    	if (err) throw err
    })
    connection.end()
    //    colN.forEach(function(i,j){console.log(i);})
    for(var r=1;r<tabD.length;r++){
	//var dataString = tabD[r].join(",");
	for(var c=0;c<tabD[r].length;c++){
	    csvContent += tabD[r][c].text().replace(/[%]/g,"") + ',';
	}
	csvContent += "\n";
    }
    //console.dir(csvContent);

    // log(tabV);
    // body = body.replace('var bk_results = ','')
    // body = body.substring(0, body.length-2)
    // //console.log(body)
    // campaigns = ''
    // for(i in body.campaigns){
    // 	campaigns += body.campaigns[i].campaign + ' '
    // }
    // console.log("TEST #" + loopIndex + " :: " + campaigns)
    // requestJSONReturn(++loopIndex)
}

requestJSONReturn = (loopIndex) =>{
    if(loopIndex >= testLoop)
	return
    
    request({url:baseUrl
	     ,qs:{from: 'blog example', time: +new Date()} //Query string data
	     ,method: 'GET'
	     ,headers:headerD
	     //,body:bodyReq
	     //,form:formD
	    }
	    , function (error, response, body) {
		if (!error && response.statusCode == 200) {
		    readIt(body);
		}
	    })
}

requestJSONReturn(0);

