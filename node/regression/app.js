var express = require('express');
var session = require('express-session');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var path = require('path');

var index = require('./routes/index');
var users = require('./routes/users');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
//app.engine('html', require('ejs').renderFile);
//app.set('view engine', 'html');
app.set('view engine', 'jade');

// uncomment after placing your favicon in /public
//app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', index);
app.use('/users', users);

app.use(session({ secret: '$#%!@#@@#SSDASASDVV@@@@', key: 'sid'}));

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});
//--------------------------------log-in-----------------------------------
var sess;
app.get('/login',function(req,res){
    res.sendfile("login.html");
    sess=req.session;
    if(user_have_logged_in){
	sess.email=req.body.email;
	res.json({"yes":"1"});
    }
    else{res.json({"yes":"0"});}
});
app.post('/login',function(req,res){
  var user_name=req.body.user;
  var password=req.body.password;
  console.log("User name = "+user_name+", password is "+password);
  res.end("yes");
});
app.get('/logout',function(req,res){
       res.json({"logout":"yes"});
});
app.get('/profile',function(req,res){
       var profile_id=req.query.id;
       res.render('profile',{id:profile_id});
});
app.get('/profile',function(req,res){
    sess=req.session;
    if(sess.email){res.render('profile',{email:sess.email});}
    else{res.redirect('/');}
});
app.get('/logout',function(req,res){
     sess=req.session;
     if(sess.email){
         req.session.destroy(function(err){
         if(err){console.log(err);}
         else{res.redirect('/');}
	 })
     }
     else{res.redirect('/');}
});
//-----------------------------home-------------------------------------
app.get('/',function(err,req,res){
    if(err){res.send('Some issue is here');}
    else{res.send('hello world');}
});
//------------------------------error-handler----------------------------
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;


