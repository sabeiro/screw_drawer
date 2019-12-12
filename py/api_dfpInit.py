import json
import os
import argparse
import sys
from oauth2client import client
from googleads import dfp
from googleads import oauth2

##os.chdir('/home/sabeiro/lav/media')
key_file = os.environ['LAV_DIR'] + '/credenza/dfp-intertino-861da83250a9.json'
key_file2 = os.environ['LAV_DIR'] + '/credenza/dfp-intertino.json'

cred = []
with open(key_file) as f:
    cred = json.load(f)
    cred2 = []
with open(key_file2) as f:
    cred2 = json.load(f)
    DEFAULT_CLIENT_ID = cred2['client_id']
    DEFAULT_CLIENT_SECRET = cred2['client_secret']
    ##cred2['refresh_token']

flow = client.OAuth2WebServerFlow(client_id=cred2['client_id'],client_secret=cred2['client_secret'],scope=oauth2.GetAPIScope('adwords'),user_agent='Test',redirect_uri=cred2['redirect_uri'])
auth_uri = flow.step1_get_authorize_url()

# from oauth2client.client import flow_from_clientsecrets
# flow = flow_from_clientsecrets('credenza/dfp-intertino.json',scope='https://www.googleapis.com/auth/calendar',redirect_uri='http://analisi.ad.mediamond.it')


# The DFP API OAuth2 scope.
SCOPE = u'https://www.googleapis.com/auth/dfp'

parser = argparse.ArgumentParser(description='Generates a refresh token with '
                                 'the provided credentials.')
parser.add_argument('--client_id', default=DEFAULT_CLIENT_ID,
                    help='Client Id retrieved from the Developer\'s Console.')
parser.add_argument('--client_secret', default=DEFAULT_CLIENT_SECRET,
                    help='Client Secret retrieved from the Developer\'s '
                    'Console.')
parser.add_argument('--additional_scopes', default=None,
                    help='Additional scopes to apply when generating the '
                    'refresh token. Each scope should be separated by a comma.')


def main(client_id, client_secret, scopes):
    """Retrieve and display the access and refresh token."""
    flow = client.OAuth2WebServerFlow(
        client_id=client_id,
        client_secret=client_secret,
        scope=scopes,
        user_agent='Ads Python Client Library',
        redirect_uri=cred2['redirect_uri'])
    #      redirect_uri='urn:ietf:wg:oauth:2.0:oob')

  authorize_url = flow.step1_get_authorize_url()

  print ('Log into the Google Account you use to access your DFP account'
         'and go to the following URL: \n%s\n' % (authorize_url))
  print 'After approving the token enter the verification code (if specified).'
  code = raw_input('Code: ').strip()

  try:
      credential = flow.step2_exchange(code)
  except client.FlowExchangeError, e:
      print 'Authentication has failed: %s' % e
      sys.exit(1)
  else:
      print ('OAuth2 authorization successful!\n\n'
             'Your access token is:\n %s\n\nYour refresh token is:\n %s'
             % (credential.access_token, credential.refresh_token))


if __name__ == '__main__':
    args = parser.parse_args()
    configured_scopes = [SCOPE]
  if not (any([args.client_id, DEFAULT_CLIENT_ID]) and
          any([args.client_secret, DEFAULT_CLIENT_SECRET])):
    raise AttributeError('No client_id or client_secret specified.')
  if args.additional_scopes:
      configured_scopes.extend(args.additional_scopes.replace(' ', '').split(','))
      main(args.client_id, args.client_secret, configured_scopes)


