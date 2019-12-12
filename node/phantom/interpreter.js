const app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
//var CronJob = require('cron').CronJob;const HORSEMAN = require('node-horseman');
const YAML = require('yamljs')
const __config = YAML.load('./config/config.yaml')
//var horseman = new Horseman({cookiesFile: ‘cookies.json’});
var sites = __config.sites.slice(0);
var checkTagVersion = function(url){
    emitter("CHECK: " + url)
    var tagVersion = "NOT PRESENT"
    var lastStatus = "404"
    var horseman = new HORSEMAN(); //{timeout: 25000}  horseman
	.userAgent("Mozilla/5.0 (Windows NT 6.1; WOW64; rv:27.0) Gecko/20100101 Firefox/27.0")
	.on('resourceRequested', ((requestData, networkRequest)) =>{
	    console.log("--- NETWORK REQIEST ---")
	    console.log(requestData)
	    console.log(networkRequest)
	    console.log("-----------")
	})
	.open(url)
	.status()
	.then(function (status) {
	    lastStatus = status
	})
	.cookies()
	.then(function(cookies){
	    for(i in cookies){
		console.log("---- COOKIES ----")
		console.log(cookies[i].name)
		console.log("-----------")
	    }
	    return tagVersion
	})
	.finally(function(tv){ //finally
	    horseman.close();
	    if (Number(lastStatus) != 200) {
		emitter(":warning: Couldn't load page, trying again...");
		checkAllSites(url)
		return
	    }
	    else{
		emitter("---> v." + tagVersion + "\n")
		checkAllSites()
	    }
	});
}

var checkAllSites = function(url){
    if(url)
	checkTagVersion(url)
    else if(sites.length > 0)
	checkTagVersion(sites.shift())
    else {
	emitter("CHECK ENDED");
	//horseman.close();
	sites = __config.sites.slice(0);
	console.log(__config.sites)
	return;
    }
}
//checkAllSites()
//checkTagVersion('http://www.grazia.it')
app.get('/', function(req, res){
    res.sendfile('./static/index.html');
});
app.get('/static/:file', function(req, res){
    res.sendfile('./static/' + req.params.file);
});
app.get('/start', function(req, res){
    checkAllSites()
    res.send('OK');
});
io.on('connection', function(socket){
    console.log('a user connected');
});
http.listen(__config.server.port, __config.server.ip_adress, function(){
    console.log('listening on *:' +__config.server.port);
});
function emitter(msg){
    io.emit('log-message', msg)
} 



