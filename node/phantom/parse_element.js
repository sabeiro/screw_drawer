var page = require('webpage').create();

// hook into initial request
page.onResourceRequested = function(request) {
    console.log('Request ' + JSON.stringify(request, undefined, 4));
};

// hook to response
page.onResourceReceived = function(response) {
    console.log('Receive ' + JSON.stringify(response, undefined, 4));
};

page.open('https://dauvi.org');

// webpage.open('https://scotch.io', function(status) {
//     if (status !== 'success') {
//         console.log('Unable to access network');
//     } else {
//         var title = webpage.evaluate(function() {
//             return document.title;
//         });

//      // log the title
//         console.log(title === 'Scotch | Developers bringing fire to the people.');
//     }

//     phantom.exit();
// });
