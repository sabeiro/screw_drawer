// https://devportal.bluekai.com/audienceapi
// https://devportal.bluekai.com/userdataapi
// https://devportal.bluekai.com/siteapi
// https://devportal.bluekai.com/campaignapi
// https://devportal.bluekai.com/countriesapi
// https://devportal.bluekai.com/verticalapi
// https://devportal.bluekai.com/pingapi
// https://devportal.bluekai.com/class_cat_api
// https://devportal.bluekai.com/class_rule_api
// https://devportal.bluekai.com/inventory_reach_api
// https://devportal.bluekai.com/segment_reach_api
// https://devportal.bluekai.com/pixelurlapi
//29137
//30931
//6lQ99YpqbkRTgS6g

var bkuid="750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f";
var bksig="0e3cb02cacfcca23724e25515b4cbe61b2ac954dc0fc495d1daadd246eddd0c5";

var campU = "services.bluekai.com/Services/WS/Campaign?";// + bkuid + bksig;

var campR = $.get(campU,{bkuid:bkuid,bksig:bksig});
