var webpage = require('webpage').create();

webpage.open('https://scotch.io/', function() {
    webpage.render('scotch.png');
    phantom.exit();
});
