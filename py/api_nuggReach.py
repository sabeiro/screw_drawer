import oauth2
from oauth2client.client import flow_from_clientsecrets
from oauth2client.client import OAuth2WebServerFlow
from wsgiref.simple_server import make_server
import oauth2
import oauth2.grant
import oauth2.error
import oauth2.store.memory
import oauth2.tokengenerator
import oauth2.web.wsgi
import json

key_file = os.environ['LAV_DIR'] + '/credenza/gemini.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)

nuggad_api    = 'https://api.nuggad.net'
oauth_client = OAuth2::Client.new(cred['client_id'],cred['client_secret'], :site => nuggad_api)
token = oauth_client.password.get_token(cred['user_name'], cred['password'])
response = token.get('/networks', :format => 'json')
puts response.body

class ExampleSiteAdapter(oauth2.web.AuthorizationCodeGrantSiteAdapter,
                         oauth2.web.ImplicitGrantSiteAdapter):
    def authenticate(self, request, environ, scopes, client):
        if request.post_param("confirm") == "confirm":
            return {}
        raise oauth2.error.UserNotAuthenticated
    def render_auth_page(self, request, response, environ, scopes, client):
        response.body = '''<html><body><form method="POST" name="confirmation_form"><input type="submit" name="confirm" value="confirm" /> <input type="submit" name="deny" value="deny" /></form></body></html>'''
        return response
    def user_has_denied_access(self, request):
        if request.post_param("deny") == "deny":
            return True
        return False

client_store = oauth2.store.memory.ClientStore()
client_store.add_client(client_id="abc", client_secret="xyz",redirect_uris=["http://localhost/callback"])
site_adapter = ExampleSiteAdapter()
token_store = oauth2.store.memory.TokenStore()
provider = oauth2.Provider(
    access_token_store=token_store,
    auth_code_store=token_store,
    client_store=client_store,
    token_generator=oauth2.tokengenerator.Uuid4()
)

# Add Grants you want to support
provider.add_grant(oauth2.grant.AuthorizationCodeGrant(site_adapter=site_adapter))
provider.add_grant(oauth2.grant.ImplicitGrant(site_adapter=site_adapter))

# Add refresh token capability and set expiration time of access tokens
# to 30 days
provider.add_grant(oauth2.grant.RefreshToken(expires_in=2592000))

# Wrap the controller with the Wsgi adapter
app = oauth2.web.wsgi.Application(provider=provider)

if __name__ == "__main__":
    httpd = make_server('', 8080, app)
    httpd.serve_forever()


flow = OAuth2WebServerFlow(client_id='your_client_id',
                           client_secret='your_client_secret',
                           scope='https://www.googleapis.com/auth/calendar',
                           redirect_uri='http://example.com/auth_return')

flow = flow_from_clientsecrets('path_to_directory/client_secrets.json',
                               scope='https://www.googleapis.com/auth/calendar',
                               redirect_uri='http://example.com/auth_return')




client_secret = "xyz"
api_server_url = "http://localhost:8080"
def __init__(self):
    self.access_token = None
    self.auth_token = None
    self.token_type = ""
def __call__(self, env, start_response):
    if env["PATH_INFO"] == "/app":
        status, body, headers = self._serve_application(env)
    elif
    env["PATH_INFO"] == "/callback":
    status, body, headers = self._read_auth_token(env)
    else:
        status = "301 Moved"
        body = ""
        headers = {"Location": "/app"}
        start_response(status,[(header, val) for header,val in headers.iteritems()])
        return body
def _request_access_token(self):
    print ("Requesting access token...")
    post_params = {"client_id": self.client_id,
                   "client_secret": self.client_secret,
                   "code": self.auth_token,
                   "grant_type": "authorization_code",
                   "redirect_uri": self.callback_url}
    token_endpoint = self.api_server_url + "/token"
    result = urllib.urlopen(token_endpoint,urllib.urlencode(post_params))
    content = ""
    for line in result:
        content += line
        result = json.loads(content)
        self.access_token = result["access_token"]
        self.token_type = result["token_type"]
        confirmation = "Received access token '%s' of type '%s'" % (self.access_token, self.token_type)
        print (confirmation)
        return "302 Found", "", {"Location": "/app"}
def _read_auth_token(self, env):
    print ("Receiving authorization token...")
    query_params = urlparse.parse_qs(env["QUERY_STRING"])
    if "error" in query_params:
        location = "/app?error=" + query_params["error"][0]
        return "302 Found", "", {"Location": location}
    self.auth_token = query_params["code"][0]
    print ("Received temporary authorization token '%s'" % (self.auth_token,))
    return "302 Found", "", {"Location": "/app"}

def _request_auth_token(self):
    print ("Requesting authorization token...")
    auth_endpoint = self.api_server_url + "/authorize"
    query = urllib.urlencode({"client_id": "abc","redirect_uri": self.callback_url,"response_type": "code"})
    location = "%s?%s" % (auth_endpoint, query)
    return "302 Found", "", {"Location": location}
def _serve_application(self, env):
    query_params = urlparse.parse_qs(env["QUERY_STRING"])
    if("error" in query_params and query_params["error"][0] == "access_denied"):
        return "200 OK", "User has denied access", {}
    if self.access_token is None:
        if self.auth_token is None:
            return self._request_auth_token()
        else :
            return self._request_access_token()
    else:
        confirmation = "Current access token '%s' of type '%s'" % (self.access_token, self.token_type)
        return "200 OK", str(confirmation), {}
def run_app_server():
    app = ClientApplication()
    try:
        httpd = make_server('', 8081, app, handler_class=ClientRequestHandler)
        print ("Starting Client app on http://localhost:8081/...")
        httpd.serve_forever()
    except KeyboardInterrupt:
        httpd.server_close()
def run_auth_server():
    client_store = ClientStore()
    client_store.add_client(client_id="abc", client_secret="xyz",
                            redirect_uris=["http://localhost:8081/callback"])
    token_store = TokenStore()
    provider = Provider(access_token_store=token_store,
                        auth_code_store=token_store, client_store=client_store,
                        token_generator=Uuid4())
    provider.add_grant(AuthorizationCodeGrant(site_adapter=TestSiteAdapter()))
    try:
        app = Application([url(provider.authorize_path, OAuth2Handler, dict(provider=provider)),
    url(provider.token_path, OAuth2Handler, dict(provider=provider)),
])
    app.listen(8080)
    print ("Starting OAuth2 server on http://localhost:8080/...")
    IOLoop.current().start()
    except KeyboardInterrupt:
        IOLoop.close()
def main():
    auth_server = Process(target=run_auth_server)
    auth_server.start()
    app_server = Process(target=run_app_server)
    app_server.start()
    print ("Access http://localhost:8081/app in your browser")
def sigint_handler(signal, frame):
    print ("Terminating servers...")
    auth_server.terminate()
    auth_server.join()
    app_server.terminate()
    app_server.join()
    signal.signal(signal.SIGINT, sigint_handler)

if __name__ == "__main__":
    main()
