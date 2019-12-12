var header = {"date":"Wed, 08 Jun 2016 16:23:50 GMT","x-request-id":"7bc70d64-f72d-44a5-af25-b2a9f9cf9a20","set-cookie":["JSESSIONID=2FE90D89D6C70B610FD5C33D113B9C65; Path=/Services; HttpOnly"],"content-type":"text/plain","vary":"Accept-Encoding","nncoection":"close","transfer-encoding":"chunked"};
var response = "{\"unknownCategories\":[{\"reach\":556800,\"cat\":515450},{\"reach\":5611194240,\"cat\":408098}],\"multiplier\":1920,\"reach\":258560,\"priceFloor\":0,\"AND\":[{\"reach\":258560,\"priceFloor\":0,\"AND\":[{\"OR\":[{\"reach\":258560,\"priceFloor\":0,\"AND\":[{\"reach\":564480,\"priceFloor\":0,\"cat\":515450,\"nvars\":6},{\"OR\":[{\"reach\":5609731840,\"priceFloor\":0,\"cat\":408098,\"nvars\":6}],\"reach\":5609731840,\"priceFloor\":0,\"nvars\":6}],\"nvars\":6}],\"reach\":258560,\"priceFloor\":0,\"nvars\":6}],\"nvars\":6}],\"_cpuTime\":51,\"namespaces\":[1],\"nvars\":6,\"status\":\"QUERY_SUCCESS\"}";

var url='services.bluekai.com/Services/WS/SegmentInventory';

var cred={"apiKey":"2a485752a542f032f7442c5a62ce97d070d72676","apiName":"segment_reach_api","apiSecret":"011fd10c1c5ce2ec8a7e37322712a422f912a93984ff58eb48bc5625dc4c5f91"};


function setHeader(xhr) {
 xhr.setRequestHeader('Authorization','12345');
 xhr.setRequestHeader('SomethingElse','abcdefg');
}

var data = {"AND":[{"AND":[{"OR": [{"cat": 515450}]}]}]};

var data = {
    "params": {},
    "version": "1.1",
    "method": "getConnectionTest"
}

var url = 'http://report2.webtrekk.de/cgi-bin/wt/JSONRPC.cgi'

$.ajax( {
    url: url,
    type: 'POST',
    datatype: 'jsonp',
    data : data,
    beforeSend : function( xhr ) {
        //xhr.setRequestHeader('Authorization','BEARER ' + cred.apiKey);
        //xhr.setRequestHeader('Authorization','BEARER ' + cred.apiSecret);
    },
    success: function( response ) {
        console.log(response);
    },
    error : function(error) {
        console.log(error);
    }
} );


$.ajax({
    url: url,
    type: 'POST',
    datatype: 'json',
    headers: { "Content-Type":"application/json","Accept": "application/json","Authorization": "OAuth oauth_token=ACCESSTOKEN" },
    data: data,
    success: function() { alert("Success"); },
    error: function() { alert('Failure!'); },
    beforeSend: setHeader

});



curl --request 'POST' 'https://api.twitter.com/1.1/' --header 'Authorization: OAuth oauth_consumer_key="BzRHnmn0QY7OsS5Jmvgt84SGa", oauth_nonce="63a44affaf2c44f12c2041724260890e", oauth_signature="hTWZd6yUls0jAKBhT%2F2nCJN7rXg%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1465465764", oauth_token="2366955595-M7eAtsN5sEnwe3KyiujVFVXQyGJyZkvmeb5CWCc", oauth_version="1.0"' --verbose

curl --get 'https://api.twitter.com/1.1/' --header 'Authorization: OAuth oauth_consumer_key="BzRHnmn0QY7OsS5Jmvgt84SGa", oauth_nonce="ef4da526d3ed1f4983da17fc6301ffe7", oauth_signature="82HgfPnSKHOig4%2BJErNFJpM9eQs%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1465465793", oauth_token="2366955595-M7eAtsN5sEnwe3KyiujVFVXQyGJyZkvmeb5CWCc", oauth_version="1.0"' --verbose
