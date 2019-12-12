var  name= 'RTI DMP Mediamond JSON Mediamond ',
    uid='750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f',
    secretkey= '0e3cb02cacfcca23724e25515b4cbe61b2ac954dc0fc495d1daadd246eddd0c5',
    BK_site_ID= [], //29139,29140,30579,30580,30099,30100,30581,30582,29137,29138,28415,28416
    BK_partner_ID= 3256;


var params = $(this).serializeArray(),
    apiKey = { name: 'apiKey', value: $('input[name=key]').val() },
    apiSecret = { name: 'apiSecret', value: $('input[name=secret]').val() },
    apiName = { name: 'apiName', value: $('input[name=apiName]').val() };
params.push(apiKey, apiSecret, apiName);

$.post('/processReq', params, function(result, text) {
    // If we get passed a signin property, open a window to allow the user to signin/link their account
    if (result.signin) {
        window.open(result.signin,"_blank","height=900,width=800,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0");
    } else {
        var response,
            responseContentType = result.headers['content-type'];
        // Format output according to content-type
        response = livedocs.formatData(result.response, responseContentType);
	
        $('pre.response', resultContainer)
            .toggleClass('error', false)
            .text(response);
    }
})



var sha256 = new jsSHA('SHA-256', 'TEXT');
sha256.update(secretkey);
var hash = sha256.getHash("HEX");
var urlApi = "//services.bluekai.com/Services/WS/" + "?bkuid=" + uid + "&bksig=" + hash;
var urlApi = 'services.bluekai.com/Services/WS/audiences?bkuid=750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f&bksig=p1cKHJ4B1JSZyp2AqTlCs60pUpVDdp%2FDsCljNkvwAR0%3D';

var cdata = (function() {
    var json = null;
    $.ajax({
        async: false,
        global: false,
        url: resp,
        dataType: "jsonp",
        success: function (data) {
            json = data;
        },
        failure: function() {alert("problem with the file" + jData); }
    });
    return json;
})();

