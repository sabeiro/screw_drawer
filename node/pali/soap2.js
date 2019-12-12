// test-initialization-script.js
var sinon = require('sinon');
var soapStub = require('soap/soap-stub');

var urlMyApplicationWillUseWithCreateClient = 'http://osb11g.mediaset.it:8021/PalinsestiOSB/PS/PS_MHPService?getMHPData';
var clientStub = {
  SomeOperation: sinon.stub()
};

var errJ = {"msg":"error"}
var sucJ = {"msg":"error"}

clientStub.SomeOperation.respondWithError = soapStub.createErroringStub(errJ);
clientStub.SomeOperation.respondWithSuccess = soapStub.createRespondingStub(sucJ);

soapStub.registerClient('my client alias', urlMyApplicationWillUseWithCreateClient, clientStub);

// test.js
var soapStub = require('soap/soap-stub');

describe('myService', function() {
  var clientStub;
  var myService;

  beforeEach(function() {
    clientStub = soapStub.getStub('my client alias');
    soapStub.reset();
    myService.init(clientStub);
  });

  describe('failures', function() {
    beforeEach(function() {
      clientStub.SomeOperation.respondWithError();
    });

    it('should handle error responses', function() {
      myService.somethingThatCallsSomeOperation(function(err, response) {
        // handle the error response.
      });
    });
  });
});
