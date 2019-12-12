var http = require('http');

var server = http.createServer(function (req,res){
    console.log('Requestiong',req.url);
    if(req.url === '/'){
	res.end('Hello world:');
    } else {
	res.statusCode = 404;
	res.end('404 not found =(');
    }
}).listen(8000,function(){
    console.log('Listening on http://localhost:8000');
});

window.onbeforeunload = function(){
    server.close();
}
   
	
