var express = require('express');
var router = express.Router()
var http = require("http");
var https = require("https");
var htmlparser = require("htmlparser2");
var bodyParser = require('body-parser');
var cookieParser = require('cookie-parser');
var crypto = require('crypto');
var fs = require('fs');
var obj = JSON.parse(fs.readFileSync('../../../credenza/intertino.json', 'utf8'));
var sqlUsr = obj.mysql.intertino
var mysql = require('mysql')
var connection = mysql.createConnection({host:sqlUsr.host,user:sqlUsr.user,password :sqlUsr.pass,database :sqlUsr.db});


var rand = function() {
    return Math.random().toString(36).substr(2); // remove `0.`
};

var token = function() {
    //return rand() + rand(); // to make it longer
    return crypto.randomBytes(48).toString('hex')
};

var app = express();
app.use(cookieParser())
app.set('views',__dirname + '/views');
app.set('view engine', 'ejs');
app.engine('html', require('ejs').renderFile);

app.use(bodyParser.urlencoded({ extended: false }));
//app.use(express.bodyParser());
var myLogger = function (req, res, next) {
  console.log('LOGGED')
  next()
}
app.use(function (req, res, next) {
    console.log('Time:', Date.now())
    console.log('body:', req.body)
    next()
})
app.get('/', function (req, res) {
    res.send('hello world')
})
app.get('/user/:id', function (req, res, next) {
  res.send('USER')
})
app.post('/', function(req, res) {
    connection.connect()
    var queryD = "SELECT * FROM login;"
    connection.query(queryD,function (err, rows, fields) {
	if (err) throw err
	console.log('The solution is: ', rows[0])
    })
    connection.end()
    console.log(req.body);// the posted data
    var repD = {"token":token()};
    res.send(repD);
});
router.post("/users",function(req,res){
    res.send(JSON.stringify(req.body, null, 4));
});

module.exports = function(app)
{
     app.get('/',function(req,res){
        res.render('index.html')
     });
     app.get('/about',function(req,res){
        res.render('about.html');
    });
}

var server = app.listen(8888,function(){
    console.log("Express running on port 8888");
}



// var cassandra = require('cassandra-driver')
// var client = new cassandra.Client({ contactPoints: ['localhost'] })
// client.execute('select key from system.local', function (err, result) {
//   if (err) throw err
//   console.log(result.rows[0])
// })





// var MongoClient = require('mongodb').MongoClient
// MongoClient.connect('mongodb://localhost:27017/animals', function (err, db) {
//   if (err) throw err
//   db.collection('mammals').find().toArray(function (err, result) {
//     if (err) throw err
//     console.log(result)
//   })
// })
// var apoc = require('apoc')//neo4j
// apoc.query('match (n) return n').exec().then(
//   function (response) {
//     console.log(response)
//   },
//   function (fail) {
//     console.log(fail)
//   }
// )
// var pgp = require('pg-promise')(/*options*/)
// var db = pgp('postgres://username:password@host:port/database')
// db.one('SELECT $1 AS value', 123)
//   .then(function (data) {
//     console.log('DATA:', data.value)
//   })
//     .catch(function (error) {
// 	console.log('ERROR:', error)
//     })
	





//curl -d user=Someone -H Accept:application/json --url http://localhost:8888
