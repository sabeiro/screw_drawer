var
_mode = "_dev"
_server_port = 8099
verbose = true
api_base_url = "http://services.bluekai.com/"
limboExpireDate = new Date().getTime() - (0 * 24 * 60 * 60 * 1000) //  day hour  min  sec  msec
headers = {"Accept":"application/json","Content-type":"application/json","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
_seats = []
_seats['_dev'] = {
    name: 'RTI DMP API Sandbox ',//utente user settings
    suffix:'_dev',
    uid:'fff7b2dbe8a0fd94bafe24133ecaf7f828fa376c7b78cfdae9a2a132fee4d1d2',
    secretkey: '964b05b5f9306760617f63fda7071830be47a23d53fb76be370773ffdc3ab236',
    masterNodeID: 515290,
    limboNodeID: 529231,
    BK_site_ID: [], //29959,29960
    BK_partner_ID: 3394
}
// SEZIONE DA COMPLETARE CON I DATI DELLA PROPRIA SEAT DI RIFERIMENTO
_seats['_prod'] = {
    name: 'RTI DMP Mediamond JSON Mediamond ',
    suffix:'_prod',
    uid:'750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f',
    secretkey: '0e3cb02cacfcca23724e25515b4cbe61b2ac954dc0fc495d1daadd246eddd0c5',
    masterNodeID: 498541,
    limboNodeID: 548031,
    BK_site_ID: [], //29139,29140,30579,30580,30099,30100,30581,30582,29137,29138,28415,28416
    BK_partner_ID: 3256
}
for(seat in _seats){_seats[seat].opml_file_path = function(){return "opml/taxonomy" + this.suffix + ".opml"};_seats[seat].backup_file_path = function(){return "backup/backup" + this.suffix + "/"};}

