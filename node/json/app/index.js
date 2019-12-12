
// DMP TAXONOMY MANAGER
// @ttessarolo
// #v.1.0 
// #2016


 
// DEPENDENCIES
var 
	UTIL = require('util')
	URL = require('url-parse')
	CRYPTO = require('crypto')
	FS = require('fs')
    REQUEST = require('request')
    CHEERIO = require('cheerio')
    SEQUENCE = require('sequence').Sequence
    RESTIFY = require('restify')
    SOCKETIO = require('socket.io')
    CHECKURL = require('valid-url')
    UTF8 = require('utf8')
    _consoleLog = console.log

// OVERWRITE CONSOLE.LOG
console.log = function(msg){
	if(verbose){
		statusUpdate("OK","CONSOLE","Console Log", msg)
		_consoleLog(msg)
	}
}

// GLOBAL PREFERENCES
require('./config/app_config.js')


// LOCAL VARIABLES
var
	$ = null
	elements = {}
	numElements = 0
	opml_categories = []
	bk_sc_categories = {}
	opml_rules = []
	bk_sc_rules = {}
	bk_sc_limbo_rules_id = []
	bk_sc_url_limbo_rules_id = []
	bk_sc_phint_limbo_rules_id = []
	ascii = /^[ -~]+$/
	OPML_Errors = 0
	RULE_Errors = 0
	_connetedUsers = 0

resetVariables = () =>{
	elements = {}
	numElements = 0
	opml_categories = []
	bk_sc_categories = {}
	opml_rules = []
	bk_sc_rules = {}
	bk_sc_limbo_rules_id = []
	bk_sc_url_limbo_rules_id = []
	bk_sc_phint_limbo_rules_id = []
	OPML_Errors = 0
}

statusUpdate = (status, origin, description, msg) => {
	//io.emit('api update', { "status": status, "origin":origin, "description":description, details: msg })
	io.emit(origin, { "status": status, "origin":origin, "description":description, details: msg })
}

packUpdate = (status, origin, description, msg) => {
	return { "status": status, "origin":origin, "description":description, details: msg }
}

var setMode = (the_mode) => {
	if(_seats[the_mode]){
		_mode = the_mode
		statusUpdate("OK","APP","Set Mode",the_mode)
		loadOPML()
	} else {
		statusUpdate("KO","APP","Set Mode",'mode not valid')
	}
}

var getMode = () => {
	return _mode
}

var signatureInputBuilder = (url, method, data) => {
	var stringToSign = method
    var parsedUrl = new URL(url)
    stringToSign += parsedUrl.pathname


    var qP = parsedUrl.query.split('&')

    if(qP.length > 0){
     	for(qs = 0; qs < qP.length; qs++){
     		var qS = qP[qs]
     		var qP2 = qS.split('=')
     		
            if (qP2.length > 1)
                stringToSign += qP2[1]
     	}    
     }


     if(data != null && data.length > 0)
     	stringToSign += data
     
     var s = CRYPTO.createHmac('sha256', _seats[_mode].secretkey).update(stringToSign).digest('base64') 
     //var s = CRYPTO.createHmac('sha256', bksecretkey).update(new Buffer(stringToSign, 'utf-8')).digest('base64')
     
     u = encodeURIComponent(s)

    var newUrl = url
    if(url.indexOf('?') == -1 )
        newUrl += '?'
    else
        newUrl += '&'
         
    newUrl += 'bkuid=' + _seats[_mode].uid + '&bksig=' + u

    return newUrl
}

var readAllOPMLOutlines = (next) => {
	FS.readFile(_seats[_mode].opml_file_path(), 'utf8',  (err,opml_data) => {
		if (err)
			return console.log(err)

		FS.writeFile(_seats[_mode].backup_file_path() + "backup" + (new Date().getTime()) + ".opml", opml_data,  (err,data) => {
			if (err)
				return console.log(err)

			$ = CHEERIO.load(opml_data, {xmlMode: true, decodeEntities: false, normalizeWhitespace: false})
			elements = $('outline')
			numElements = elements.length
			next()
		})
		
	})
}

var backupOPML = () => {
	FS.readFile(_seats[_mode].opml_file_path(), 'utf8',  (err,opml_data) => {
		if (err)
			return console.log(err)

		FS.writeFile(_seats[_mode].backup_file_path() + "backup" + (new Date().getTime()) + ".opml", opml_data,  (err,data) => {
			if (err)
				return console.log(err)
		})
		statusUpdate("OK","OPML","Back Up OPML File", _seats[_mode].opml_file_path())
	})
}

var loadOPML = () => {
	FS.readFile(_seats[_mode].opml_file_path(), 'utf8',  (err,opml_data) => {
		if (err)
			return console.log(err)

		$ = CHEERIO.load(opml_data, {xmlMode: true, decodeEntities: false, normalizeWhitespace: false})
		elements = $('outline')
		numElements = elements.length

		statusUpdate("OK","OPML","OPML File Loaded", _seats[_mode].opml_file_path())
	})

}

var writeAllOPMLOutlines = (next) => {
	FS.writeFile(_seats[_mode].opml_file_path(), $.html(), function (err,data) {
		if (err)
			return console.log(err)

		statusUpdate("OK","OPML","OPML File Write", _seats[_mode].opml_file_path())
		next()
	})
}

var doRequest = (url, method, data, next) => {
	//if(data)
	//	data = UTF8.encode(data) //(new Buffer(data)).toString('utf-8')
	var newUrl = signatureInputBuilder(url,method,data)

	var options = {
  		url: newUrl,
  		headers: headers,
  		method: method,
  		body: data	
  	}

	if(method === "POST"){
		REQUEST.post(options, function(error, data, response, body) {
		  if (error == null ) { // && !error && response.statusCode == 200
		    next(response)
			return (response)
		  } else{next()}//
		})
	}
	if(method === "GET"){
		REQUEST.get(options, function(error, response, body) {
		  if (error == null  && !error && response.statusCode == 200) {
		    next(body)
			return (body)
		  } else{next()}
		})
	}
	if(method === "PUT"){
		REQUEST.put(options, function(error, data, response, body) {
		  if (error == null  && !error && response.statusCode == 200) {
		    next(body)
			return (body)
		  } else{next(response)}
		})
	}
}

var checkRules = (nodeIndex,next) => {
	if(nodeIndex == numElements){
		status = "OK"
		if(RULE_Errors > 0)
			status = "KO"

		statusUpdate(status,"TAXONOMY","Check Rules Ended",RULE_Errors)
		next()
	}
	else{
		elem = $(elements[nodeIndex])
		

		// IDS
		var the_ids = []
		if(elem.attr('IDS'))
			the_ids = elem.attr('IDS').split(":")
		var BK_category_ID = the_ids[0] || ""
		var BK_rule_IDs = []

		if(the_ids[2] && the_ids[2].length > 0){
			BK_rule_IDs = the_ids[2].split(",") || [0]
			for(rID = 0; rID < BK_rule_IDs.length; rID++){
				ruleID = BK_rule_IDs[rID].substring(1)
				if(!checkRuleID(ruleID)){
					++RULE_Errors
					statusUpdate("KO","TAXONOMY","Check Rules Not Present",{"rule_id": ruleID, "name": elem.attr("text")})
				}
			}
		}

		checkRules(++nodeIndex, next)
	}
}

var checkRuleID = (ruleID) => {
	for(f=0; f < bk_sc_rules.rules.length; f++)
		if(bk_sc_rules.rules[f].id == ruleID)
			return true

	return false
}

var checkOPMLIntegrity = (nodeIndex, counter) => {
	
	var counter = counter || 0
	var step = Math.floor(numElements / 5)
	step = step == 0 ? 1: step

	if(nodeIndex == numElements){
		status = "OK"
		if(OPML_Errors > 0)
			status = "KO"

		statusUpdate(status,"opml","opml:check:completed",OPML_Errors)
		return null
	}
	if(nodeIndex == 0)
		OPML_Errors = 0

	if(counter == step){
		statusUpdate("OK","opml","opml:check:category", {current: nodeIndex,  total: numElements})
		counter = 0
	}
	

	elem = $(elements[nodeIndex])
	BK_category_name = elem.attr('text') || ""
	BK_phints_rule = elem.attr('BK_phints_rule') || ""  
	BK_URL_rule = elem.attr('BK_URL_rule') || ""  

	// CHECK CATEGORY TITLES
	if(BK_category_name.trim().length == 0){
		statusUpdate("KO","opml","opml:check:category_name", {category: BK_category_name,  rule: "", detail:'category name: is empty'})
		OPML_Errors++
	}
	else if (!ascii.test( BK_category_name) ){
		statusUpdate("KO","opml","opml:check:category_name", {category: BK_category_name,  rule: "", detail:'category name: invalid character'})
		OPML_Errors++
	}
	

	// CHECK FOR EMPTY LINES IN PHINTS RULE
	if(BK_phints_rule.length > 0){
		BK_phints_rule = BK_phints_rule.split("&#10;&#10;")
		for(a=0; a<BK_phints_rule.length; a++){
			ret_char_index = BK_phints_rule[a].lastIndexOf("&#10;")
			if(ret_char_index > 0) 
				ret_char_index += "&#10;".length

			if(ret_char_index == BK_phints_rule[a].length){
				statusUpdate("KO","opml","opml:check:rule:phint", {category: BK_category_name, rule: BK_phints_rule[a], detail:'rule: not permitted: empty line'})
				OPML_Errors++
			}
		}
	}

	//CHECK FOR EMPTY LINES & URL CONSISTENCY IN URL RULE
	if(BK_URL_rule.length > 0){
		if(BK_URL_rule.indexOf("&#10;&#10;") > 0){
			statusUpdate("KO","opml","opml:check:rule:url", {category: BK_category_name, rule: BK_URL_rule,detail:'rule: not permitted: empty line'})
			OPML_Errors++
		}
		BK_URL_rule = BK_URL_rule.split("&#10;")
		for(a=0; a<BK_URL_rule.length; a++){
			if (!CHECKURL.isUri(BK_URL_rule[a])){
		        statusUpdate("KO","opml","opml:check:rule:url", {category: BK_category_name, rule: BK_URL_rule[a],detail:'rule: not a valid URI'})
		        OPML_Errors++
			}
		}
	}

	checkOPMLIntegrity(++nodeIndex, ++counter)
}

var processTaxonomyOPMLNode = (nodeIndex, next) =>{
	if(nodeIndex == numElements){
		statusUpdate("OK","TAXONOMY","Taxonomy Update Ended",_mode)
		next()
	}
	else{
		elem = $(elements[nodeIndex])
		statusUpdate("OK","TAXONOMY","Taxonomy Update: Process OPML Category",elem.attr("text"))

		// READ
		var BK_category_name = elem.attr('text')
		var BK_phints_rule = elem.attr('BK_phints_rule') || ""  
		var BK_URL_rule = elem.attr('BK_URL_rule') || ""  

		// IDS
		var the_ids = []
		if(elem.attr('IDS'))
			the_ids = elem.attr('IDS').split(":")
		var BK_category_ID = the_ids[0] || ""
		var BK_category_parent_ID =  "" //the_ids[1] || ""

		var partent_IDS = elem.parent().attr("IDS")
		if(partent_IDS){
			 BK_category_parent_ID = partent_IDS.split(":")[0]
		}


		var BK_rule_IDs = []
		var BK_URL_rule_IDs = []
		var BK_PHINTS_rule_IDs = []
		var BK_URL_rule_IDs_to_LIMBO = []
		var BK_PHINTS_rule_IDs_to_LIMBO = []

		if(the_ids[2] && the_ids[2].length > 0){
			BK_rule_IDs = the_ids[2].split(",") || [0]
			for(rID = 0; rID < BK_rule_IDs.length; rID++){
				rID_type = BK_rule_IDs[rID][0]
				switch(rID_type){
					case "U":
						BK_URL_rule_IDs.push(BK_rule_IDs[rID].substring(1))
						break
					case "P":
						BK_PHINTS_rule_IDs.push(BK_rule_IDs[rID].substring(1))
						break
				}
			}
		}

		// CATEGORY ATTRIBUTES
		var cat_attr = []
		if(elem.attr('CAT'))
			cat_attr = elem.attr('CAT').split(":")
		var BK_category_navigation_only = cat_attr[0] || "false"
		var BK_category_analytics_excluded = cat_attr[1] || "false"
		var BK_category_mutex_children = cat_attr[2] || "false"
		elem.attr('CAT',BK_category_navigation_only+":"+BK_category_analytics_excluded+":"+BK_category_mutex_children)

		// TOTAL RULES
		var BK_phints_rule_length = 0
		if(BK_phints_rule.length > 0){
			BK_phints_rule = BK_phints_rule.split("&#10;&#10;")
			BK_phints_rule_length = BK_phints_rule.length
		}

		var BK_URL_rule_length = 0
		if(BK_URL_rule.length > 0)
			BK_URL_rule_length = 1

		var tot_rules = BK_phints_rule_length + BK_URL_rule_length
		var required_ids = tot_rules - BK_rule_IDs.length 
		var required_URL_ids =  BK_URL_rule_length - BK_URL_rule_IDs.length
		var required_PHINTS_ids = BK_phints_rule_length - BK_PHINTS_rule_IDs.length


		SEQUENCE.create()
			.then((tax_node_seq_next) => {
				// VERIFY NEW CATEGORY
				if(BK_category_ID == "" || BK_category_ID == null){
					if(cat_in_limbo = category_find_in_limbo()) {
						BK_category_ID = cat_in_limbo.id
						tax_node_seq_next()
					}
					else { 
						SEQUENCE.create()
						.then((tax_new_cat_seq_next) => {
							var cat_to_create = {
						  		"name": BK_category_name,
								"parent_id": BK_category_parent_ID,
								"description": "MEDIASET",
								"analytics_excluded": BK_category_analytics_excluded,
								"navigation_only": BK_category_navigation_only,
								"mutex_children": BK_category_mutex_children,
								"notes": ""
	  						}
							createNewCategory(cat_to_create, tax_new_cat_seq_next)
						})
						.then((tax_new_cat_seq_next,res) => {
							statusUpdate("OK","TAXONOMY","Taxonomy New Category Created",res)
				    		BK_category_ID = res.id
							tax_node_seq_next()
						})
					}
				} 
				else
					tax_node_seq_next()
			})
			.then((tax_node_seq_next) => {
				// SET CATEGORY ATTRIBUTES & PUSH THE CATEGORY
				opml_categories.push({
			  		"id": BK_category_ID,
			  		"name": BK_category_name,
					"parent_id": BK_category_parent_ID,
					"description": "MEDIASET",
					"analytics_excluded": BK_category_analytics_excluded,
					"navigation_only": BK_category_navigation_only,
					"mutex_children": BK_category_mutex_children,
					"notes": ""
			  	})
				tax_node_seq_next()
			})
			.then((tax_node_seq_next) => {
				// GENERATE REQUIRED LIMBO RULES
				generate_limbo_rules(required_PHINTS_ids - bk_sc_phint_limbo_rules_id.length, "phint", tax_node_seq_next)
			})
			.then((tax_node_seq_next) => {
				generate_limbo_rules(required_URL_ids - bk_sc_url_limbo_rules_id.length,"url", tax_node_seq_next)
			})
			.then((tax_node_seq_next) => {
				// GET LIMBO IDS
				BK_URL_rule_IDs = BK_URL_rule_IDs.concat(get_rules_id_in_limbo(required_URL_ids, "url"))
				BK_PHINTS_rule_IDs = BK_PHINTS_rule_IDs.concat(get_rules_id_in_limbo(required_PHINTS_ids, "phint"))
				

				// DETERMINE IF THERE ARE RULES TO LIMBO
				if(required_PHINTS_ids < 0)
					for(rlimbo = 0; rlimbo < Math.abs(required_PHINTS_ids); rlimbo++)
						BK_PHINTS_rule_IDs_to_LIMBO.push(BK_PHINTS_rule_IDs.shift())
				
				if(required_URL_ids < 0)
					for(ulimbo = 0; ulimbo < Math.abs(required_URL_ids); ulimbo++)
						BK_URL_rule_IDs_to_LIMBO.push(BK_URL_rule_IDs.shift())

				// RECONSTRUCT IDS
				the_ids = BK_category_ID + ":" + BK_category_parent_ID + ":" + prefix_rules("U",BK_URL_rule_IDs).concat(prefix_rules("P",BK_PHINTS_rule_IDs)).toString()

				// SET ATTRIBUTES TO OPML
				elem.attr('IDS',the_ids)

				tax_node_seq_next()
			})
			.then((tax_node_seq_next) => {
				// PROCESS PHINTS RULES
				for(j=0; j < BK_phints_rule.length; j++){
					var the_phint_rule = BK_phints_rule[j].replace(/&#10;/g,",").replace(/‘|'/g, '"').replace(/’/g,'"').split(",")

					// EXTRACT PHINTS
					var phints = []
					for(a=0; a< the_phint_rule.length; a += 3){

						phints.push({"key" : the_phint_rule[a].replace(/"/g,'') ,"operator" : the_phint_rule[a+1].replace(/"/g,''), "value" : the_phint_rule[a+2].replace(/"/g,'')})
					}

					// GET RULE ID
					var BK_phints_rule_ID = BK_PHINTS_rule_IDs[0]
					BK_PHINTS_rule_IDs.splice(0,1)

					// PUSH THE RULE
					opml_rules.push({
						"id": BK_phints_rule_ID,
						"name" : BK_category_ID + ":PHINTS:" + BK_category_name + "_" + (j+1) + "_" + Math.floor(Math.random()*1000000),
						"partner_id": _seats[_mode].BK_partner_ID,
						"site_ids": _seats[_mode].BK_site_ID,
						"category_ids": [BK_category_ID],
						"type": "phint",
						"phints": phints
					})
				}

				tax_node_seq_next()
			})
			.then((tax_node_seq_next) => {
				// PROCESS URL RULES
				if(BK_URL_rule.length > 2){
					BK_URL_rule = BK_URL_rule.replace(/&#10;/g,",").replace(/‘|'/g, '"').replace(/’/g,'"').split(",")
					var BK_URL_rule_ID = BK_URL_rule_IDs[0]
						BK_URL_rule_IDs.splice(0,1)

					opml_rules.push({
			  			"id": BK_URL_rule_ID,
			  			"name" : BK_category_ID + ":URL:" + BK_category_name + "_1" + "_" + Math.floor(Math.random()*1000000),
						"type": "url",
						"urls": BK_URL_rule, 
						"referrer": "false",
						"exact": "false",
						"partner_id": _seats[_mode].BK_partner_ID,
						"site_ids": _seats[_mode].BK_site_ID,
						"category_ids": [BK_category_ID]
					})
				}
				tax_node_seq_next()
			})
			.then((tax_node_seq_next) => {
				// LIMBO RULES
				for(urllimbo = 0 ; urllimbo < BK_URL_rule_IDs_to_LIMBO.length; urllimbo++){
					opml_rules.push({
						"id" : BK_URL_rule_IDs_to_LIMBO[urllimbo],
						"name" : "TBD " + Math.floor(Math.random()*1000000),
						"type" : "url",
						"partner_id": _seats[_mode].BK_partner_ID,
						"site_ids": _seats[_mode].BK_site_ID,
						"category_ids": [_seats[_mode].limboNodeID],
						"urls" : ['http://www.limbo.limbo']
					})
				}
				for(phintlimbo = 0 ; phintlimbo < BK_PHINTS_rule_IDs_to_LIMBO.length; phintlimbo++){
					opml_rules.push({
						"id" : BK_PHINTS_rule_IDs_to_LIMBO[phintlimbo],
						"name" : "TBD " + Math.floor(Math.random()*1000000),
						"type" : "phint",
						"partner_id": _seats[_mode].BK_partner_ID,
						"site_ids": _seats[_mode].BK_site_ID,
						"category_ids": [_seats[_mode].limboNodeID],
						"phints" : [{ key: 'keywords', operator: 'contains', value: 'limbo' }],
					})
				}
				tax_node_seq_next()
			})
			.then((tax_node_seq_next) => {
				processTaxonomyOPMLNode(++nodeIndex,next)
			})	
	}
}

var createNewCategory = (cat_to_create, tax_new_cat_seq_next) => {
	SEQUENCE.create()
		.then((new_cat_seq_next) => {
			doRequest("http://services.bluekai.com/Services/WS/classificationCategories","POST",JSON.stringify(cat_to_create), new_cat_seq_next)
		})
		.then((new_cat_seq_next, res) => {
			tax_new_cat_seq_next(JSON.parse(res))
		})
}

var category_exist_in_taxonomy = (cat_id) => {
	for(x=0; x < opml_categories.length; x++)
		if (opml_categories[x].id == cat_id) return true
	return false
}

var category_find_in_limbo = () => {
	for(z=0; z < bk_sc_categories.categories.length; z++){
		var limboFoundCat = bk_sc_categories.categories[z]
		var update_date = new Date(limboFoundCat.updated_at.substring(0,limboFoundCat.updated_at.lastIndexOf("-")).replace(" ","T")).getTime()

		if (limboFoundCat.parent_id == _seats[_mode].limboNodeID && update_date <= limboExpireDate){ // LIMBO EXPIRE DATE!
			bk_sc_categories.categories.splice(z, 1)
			return limboFoundCat 
		}
	}
	return null
}

var categories_limbo_deleted = (next) =>{
	for(k=0; k < bk_sc_categories.categories.length; k++){
		if (bk_sc_categories.categories[k].id != _seats[_mode].limboNodeID && !category_exist_in_taxonomy(bk_sc_categories.categories[k].id)){
			opml_categories.push({
		  		"id": bk_sc_categories.categories[k].id,
		  		"name": "TBD",
				"parent_id": _seats[_mode].limboNodeID,
				"description": "",
				"analytics_excluded": "true",
				"navigation_only": "true",
				"mutex_children": "true",
				"notes": ""
	  		})
	  		
	  		rules_limbo_deleted(bk_sc_categories.categories[k].id)
		} 
	}
	next()
	return false
}

var rule_find_in_limbo = () => {
	for(f=0; f < bk_sc_rules.rules.length; f++){
		var limbo_rule = bk_sc_rules.rules[f]
		if(limbo_rule.category_ids[0] == _seats[_mode].limboNodeID){
			bk_sc_rules.rules.splice(f, 1)
			return limbo_rule
		}
	}
	return null
}

var generate_limbo_rules = (how_many, type, next) => {
	if(how_many <= 0){
		next()
		return
	}

	SEQUENCE.create()
		.then((new_rule_seq_next) => {
			var rule_to_create = {}
			switch(type){
				case "url":
					rule_to_create = {
						"name": "LIMBO_TEMP:" + how_many + ":" + Math.floor(Math.random()*1000000),
						"type": "url",
						"partner_id": _seats[_mode].BK_partner_ID,
						"site_ids": _seats[_mode].BK_site_ID,
						"category_ids": [_seats[_mode].limboNodeID],
						"urls":  ["http://www.limbo.limbo"],
						"referrer": false,
						"exact": false
					}
					break
				case "phint":
					rule_to_create = {
						"name": "LIMBO_TEMP:" + how_many + ":" + Math.floor(Math.random()*1000000),
						"type": "phint",
						"partner_id": _seats[_mode].BK_partner_ID,
						"site_ids": _seats[_mode].BK_site_ID,
						"category_ids": [_seats[_mode].limboNodeID],
						"phints":  [{"key":"keywords","value":"limbo","operator":"is"}]
					}
					break
			}
			
			doRequest("http://services.bluekai.com/Services/WS/classificationRules","POST",JSON.stringify(rule_to_create), new_rule_seq_next)
		})
		.then((new_rule_seq_next, res) => {
			bk_sc_limbo_rules_id.push(JSON.parse(res).id)

			switch(type){
				case "phint":
					bk_sc_phint_limbo_rules_id.push(JSON.parse(res).id)
					break
				case "url":
					bk_sc_url_limbo_rules_id.push(JSON.parse(res).id)
					break
			}
			generate_limbo_rules(--how_many, type, next)
		})
}

var populate_rules_limbo = () => {
	for(f=0; f < bk_sc_rules.rules.length; f++){
		var limbo_rule = bk_sc_rules.rules[f]
		if(limbo_rule.category_ids[0] == _seats[_mode].limboNodeID){
			bk_sc_limbo_rules_id.push(limbo_rule.id)
			switch(limbo_rule.type){
				case "phint":
					bk_sc_phint_limbo_rules_id.push(limbo_rule.id)
					break
				case "url":
					bk_sc_url_limbo_rules_id.push(limbo_rule.id)
					break
			}
			statusUpdate("KO","TAXONOMY","Chek Rules: Limbo Rule Found", limbo_rule.id)
		}
	}
	return null
}

var get_rules_id_in_limbo = (how_many, type) =>{
	var rules_id_in_limbo_to_return = []
	var rules_id_founded = 0

	if(bk_sc_limbo_rules_id.length == 0 || how_many == 0){
		return rules_id_in_limbo_to_return
	}

	switch(type){
		case "phint":
			for(t=0; t<bk_sc_phint_limbo_rules_id.length; t++){
				rules_id_in_limbo_to_return.push(bk_sc_phint_limbo_rules_id[t])

				if(++rules_id_founded == how_many){
					bk_sc_phint_limbo_rules_id.splice(0,how_many)
					return(rules_id_in_limbo_to_return)
				}
			}
			break
		case "url":
			for(t=0; t<bk_sc_url_limbo_rules_id.length; t++){
				rules_id_in_limbo_to_return.push(bk_sc_url_limbo_rules_id[t])

				if(++rules_id_founded == how_many){
					bk_sc_url_limbo_rules_id.splice(0,how_many)
					return(rules_id_in_limbo_to_return)
				}
			}
			break
	}
}

var prefix_rules = (prefix, rules) => {
	var prefixedRules = []
	for(pRules = 0; pRules < rules.length; pRules++)
		if(rules[pRules] && rules[pRules] !== undefined)
			prefixedRules[pRules] = prefix + rules[pRules];
	
	return prefixedRules
}

var rules_limbo_deleted = (cat_id) => {
	for(j=0; j < bk_sc_rules.rules.length; j++){
		var limbo_rule = bk_sc_rules.rules[j]
		if(limbo_rule.category_ids[0] == cat_id){
			// DISTINGUERE I DUE TIPI DI RULE: URL // PHINT
			opml_rules.push({
				"id" : limbo_rule.id,
				"name" : "TBD " + Math.floor(Math.random()*1000000),
				"type" : limbo_rule.type,
				"partner_id": limbo_rule.partner_id,
				"site_ids": limbo_rule.site_ids,
				"category_ids" : [_seats[_mode].limboNodeID],
				"phints" : [{ key: 'keywords', operator: 'contains', value: 'limbo' }],
				"urls" : ['http://www.limbo.limbo']

			})
		}
	}
}

var categories_update = (catUpdateIndex, next) => {
	if(catUpdateIndex == opml_categories.length){
		statusUpdate("OK","taxonomy","taxonomy:update:categories:ended",_mode)
		next()
	}
	else{
		SEQUENCE.create()
			.then((update_cat_seq_next) => {
				doRequest('http://services.bluekai.com/Services/WS/classificationCategories/' + opml_categories[catUpdateIndex].id,"PUT",JSON.stringify(opml_categories[catUpdateIndex]), update_cat_seq_next)
			})
			.then((update_cat_seq_next, res) => {
				statusUpdate("OK","taxonomy","taxonomy:update:category",{"current":(catUpdateIndex+1),"total": opml_categories.length, "category":opml_categories[catUpdateIndex]})
				categories_update(++catUpdateIndex, next)
				update_cat_seq_next()
			})
	}
}

var categories_update_parallel = (next) => {
	for(q=0; q < opml_categories.length; q++){
		if(opml_categories[q])
			doRequest('http://services.bluekai.com/Services/WS/classificationCategories/' + opml_categories[q].id,"PUT",JSON.stringify(opml_categories[q]), next)
	}
	next()
	return false
}

var rules_update = (ruleUpdateIndex, next) => {
	if(ruleUpdateIndex == opml_rules.length){
		statusUpdate("OK","taxonomy","taxonomy:update:rules:ended",_mode)
		next()
	}
	else{
		SEQUENCE.create()
			.then((update_rule_seq_next) => {
				doRequest('http://services.bluekai.com/Services/WS/classificationRules/' + opml_rules[ruleUpdateIndex].id,"PUT",JSON.stringify(opml_rules[ruleUpdateIndex]), update_rule_seq_next)
			})
			.then((update_rule_seq_next, res) => {
				statusUpdate("OK","taxonomy","taxonomy:update:rule",{"current":(ruleUpdateIndex+1),"total": opml_rules.length, "rule":opml_rules[ruleUpdateIndex]})
				rules_update(++ruleUpdateIndex, next)
				update_rule_seq_next()
			})
	}
}

var rules_update_parallel = (next) =>{
	for(r=0; r < opml_rules.length; r++){
		if(opml_rules[r]){
			//doRequest("http://services.bluekai.com/Services/WS/Ping","GET",null, next)
			doRequest('http://services.bluekai.com/Services/WS/classificationRules/' + opml_rules[r].id,"PUT",JSON.stringify(opml_rules[r]), next)
		}
	}
	next()
	return false
}

var checkSegmentsReach = (nodeIndex, next) => {
	if(nodeIndex == numElements){
		statusUpdate("OK","taxonomy","taxonomy:update:reach:ended",_mode)
		next()
	}
	else{
		elem = $(elements[nodeIndex])
		var BK_category_name = elem.attr('text')

		// IDS
		var the_ids = []
		if(elem.attr('IDS'))
			the_ids = elem.attr('IDS').split(":")
		var BK_category_ID = the_ids[0] || ""

		// BUILD BK QUERY
		var reach_query = "{'AND': [{'OR': [{'cat': "+ BK_category_ID + "}]}]}"
		
		SEQUENCE.create()
			.then((check_segment_reach_next) => {
				doRequest("http://services.bluekai.com/Services/WS/SegmentInventory?intlDataCountryID=-1", "POST", reach_query,check_segment_reach_next)
			})
			.then((check_segment_reach_next, res) => {
				var reach = 0

				res = JSON.parse(res)
				if(res !== undefined && res != '')
					reach = res["AND"][0].reach
				
				statusUpdate("OK","taxonomy","taxonomy:update:reach",{"current":(nodeIndex+1),"total": numElements, "reach":{"id": BK_category_ID, "name": BK_category_name, "reach": reach}})
				elem.attr("REACH", reach)
				checkSegmentsReach(++nodeIndex, next)
			})

	}
}

var log = (obj, msg) => {
	msg = msg || ""
	console.log(msg + UTIL.inspect(obj, false, null))
}

var updateTaxonomyAndRulesSeq2DELETE = () => {
	SEQUENCE.create()
	  .then(function(next) {
	  	resetVariables()
	  	statusUpdate("OK","taxonomy","taxonomy:update:started",_mode)
	  	statusUpdate("OK","taxonomy","taxonomy:read:opml",_mode)
	    readAllOPMLOutlines(next)
	  })
	  .then(function(next, res) {
	    doRequest('http://services.bluekai.com/Services/WS/classificationCategories',"GET",null, next)
	  })
	  .then(function(next, res){
	  	statusUpdate("OK","taxonomy","taxonomy:categories:loaded",_mode)
	  	bk_sc_categories = JSON.parse(res)
	  	next(res)
	  })
	  .then((next,res) => {
	  	doRequest('http://services.bluekai.com/Services/WS/classificationRules',"GET",null,next)
	  })
	  .then((next,res) =>{
	  	statusUpdate("OK","taxonomy","taxonomy:rules:loaded",_mode)
	  	bk_sc_rules = JSON.parse(res)
	  	populate_rules_limbo()
	  	next(res)
	  })
	  .then((next,res) => {
	  	statusUpdate("OK","taxonomy","taxonomy:update:opml",_mode)
	  	processTaxonomyOPMLNode(0, next)
	  })
	   .then((next,res) => {
	   	statusUpdate("OK","taxonomy","taxonomy:delete:categories:limbo",_mode)
	  	categories_limbo_deleted(next)
	  })
	  .then((next,res) => {
	  	statusUpdate("OK","taxonomy","taxonomy:update:categories:started",_mode)
	  	categories_update(0,next)
	  })
	  .then((next,res) => {
	  	statusUpdate("OK","taxonomy","taxonomy:update:rules:started",_mode)
	  	rules_update(0,next)
	  })
	  .then((next,res) => {
	  	statusUpdate("OK","taxonomy","taxonomy:write:opml",_mode)
	  	writeAllOPMLOutlines(next)
	  	statusUpdate("OK","taxonomy","taxonomy:update:ended",_mode)
	  })
	  .then((next,res) => {
	  	//statusUpdate("OK","taxonomy","taxonomy:update:reach:started",_mode)
	  	//checkSegmentsReachSeq()
	  	next()
	  })
}

var updateTaxonomyAndRulesSeq = () => {
	SEQUENCE.create()
	  .then(function(next) {
	  	resetVariables()
	  	statusUpdate("OK","taxonomy","taxonomy:update:started",_mode)
	  	statusUpdate("OK","taxonomy","taxonomy:read:opml",_mode)
	    readAllOPMLOutlines(next)
	  })
	  .then(function(next, res) {
	    doRequest('http://services.bluekai.com/Services/WS/classificationCategories',"GET",null, next)
	  })
	  .then(function(next, res){
	  	statusUpdate("OK","taxonomy","taxonomy:categories:loaded",_mode)
	  	bk_sc_categories = JSON.parse(res)
	  	next(res)
	  })
	  .then((next,res) => {
	  	doRequest('http://services.bluekai.com/Services/WS/classificationRules',"GET",null,next)
	  })
	  .then((next,res) =>{
	  	statusUpdate("OK","taxonomy","taxonomy:rules:loaded",_mode)
	  	bk_sc_rules = JSON.parse(res)
	  	populate_rules_limbo()
	  	next(res)
	  })
	  .then((next,res) => {
	  	statusUpdate("OK","taxonomy","taxonomy:update:opml",_mode)
	  	processTaxonomyOPMLNode(0, next)
	  })
	   .then((next,res) => {
	   	statusUpdate("OK","taxonomy","taxonomy:delete:categories:limbo",_mode)
	  	categories_limbo_deleted(next)
	  })
	   .then((next,res) => {
	  	statusUpdate("OK","taxonomy","taxonomy:write:opml",_mode)
	  	writeAllOPMLOutlines(next)
	  })
	  .then((next,res) => {
	  	statusUpdate("OK","taxonomy","taxonomy:update:categories:started",_mode)
	  	categories_update(0,next)
	  })
	  .then((next,res) => {
	  	statusUpdate("OK","taxonomy","taxonomy:update:rules:started",_mode)
	  	rules_update(0,next)
	  })
	  .then((next,res) => {
	  	statusUpdate("OK","taxonomy","taxonomy:update:ended",_mode)
	  })
	  .then((next,res) => {
	  	next()
	  })
}

var checkRulesSeq = () => {
	SEQUENCE.create()
	  .then(function(next) {
	    readAllOPMLOutlines(next)
	  })
	  .then((next,res) => {
	  	doRequest('http://services.bluekai.com/Services/WS/classificationRules',"GET",null,next)
	  })
	  .then((next,res) =>{
	  	bk_sc_rules = JSON.parse(res)
	  	populate_rules_limbo()
	  	next(res)
	  })
	  .then((next,res) => {
	  	checkRules(0, next)
	  })
}

var checkSegmentsReachSeq = () => {
	SEQUENCE.create()
	  .then(function(next) {
	    readAllOPMLOutlines(next)
	  })
	  .then((next,res) => {
	  	checkSegmentsReach(0,next)
	  })
	  .then((next,res) => {
	  	statusUpdate("OK","TAXONOMY","Taxonomy Update: Write OPML with Reach",_mode)
	  	writeAllOPMLOutlines(next)
	  })
}



// *********************************
// SERVER REST + SOCKET.IO SERVICE
// *********************************

var server = RESTIFY.createServer({
  name: '*** TAXONOMY MANAGER API SERVER ***',
  version: '1.0.0'
});
var io = SOCKETIO.listen(server.server);

server.use(RESTIFY.acceptParser(server.acceptable));
server.use(RESTIFY.queryParser());
server.use(RESTIFY.bodyParser());


// START PAGE
server.get('/', function indexHTML(req, res, next) {
	FS.readFile("./web/index.html", 'utf8',  (err,html_data) => {
		res.setHeader('Content-Type', 'text/html');
        res.writeHead(200);
        res.end(html_data);
        next();
	})
})
server.get('/api', function indexHTML(req, res, next) {
	FS.readFile("./web/api.html", 'utf8',  (err,html_data) => {
		res.setHeader('Content-Type', 'text/html');
        res.writeHead(200);
        res.end(html_data);
        next();
	})
})
server.get('/assets/js/:file', function indexHTML(req, res, next) {
	FS.readFile("./web/assets/js/"+req.params.file, 'utf8',  (err,html_data) => {
		res.setHeader('Content-Type', 'text/script');
        res.writeHead(200);
        res.end(html_data);
        next();
	})
})
server.get('/assets/css/:file', function indexHTML(req, res, next) {
	FS.readFile("./web/assets/css/"+req.params.file, 'utf8',  (err,html_data) => {
		res.setHeader('Content-Type', 'text/css');
        res.writeHead(200);
        res.end(html_data);
        next();
	})
})

// APP PREFERENCES
server.get('/app/mode/:', function (req, res, next) {
	res.send(packUpdate("OK","app:get:mode","Get Mode",_mode))
	next()
})
server.put('/app/mode/:', function (req, res, next) {
	the_mode = req.params.the_mode
	res.send(packUpdate("OK","app:set:mode","Set Mode Requested",the_mode))
	setMode(the_mode)
	next()
})
server.get('/app/users/:', function (req, res, next) {
	res.send(packUpdate("OK","app","app:user:connected",_connetedUsers))
	next()
})


// TAXONOMY
server.get('/taxonomy/:', function (req, res, next) {
	SEQUENCE.create()
	  .then(function(next) {
	  	statusUpdate("OK","TAXONOMY","Taxonomy DMP Categories Requested",_mode)
	    doRequest('http://services.bluekai.com/Services/WS/classificationCategories',"GET",null, next)
	  })
	  .then(function(next, res_cat){
	  	res.send(packUpdate("OK","TAXONOMY","Taxonomy DMP Categories",JSON.parse(res_cat)))
	  	next()
	  })
	next()
})
server.put('/taxonomy/:', function (req, res, next) {
	bk_sc_categories = {}
	bk_sc_rules = {}
	res.send(packUpdate("OK","TAXONOMY","Taxonomy Update Requested",{"partner_id":_seats[_mode].BK_partner_ID,"OPML File": _seats[_mode].opml_file_path(), "Site IDs": _seats[_mode].BK_site_ID}))
	updateTaxonomyAndRulesSeq()
	next()
})
server.get('/taxonomy/reach/:', function (req, res, next) {
	res.send(packUpdate("OK","TAXONOMY","Taxonomy Reach Requested",_mode))
	checkSegmentsReach(0,function(){})
	next()
})
server.get('/taxonomy/rules/:', function (req, res, next) {
	SEQUENCE.create()
	  .then(function(next) {
	    doRequest('http://services.bluekai.com/Services/WS/classificationRules',"GET",null,next)
	    statusUpdate("OK","TAXONOMY","Classification Rules Requested","")
	  })
	  .then(function(next, res_cat){
	  	res.send(packUpdate("OK","TAXONOMY","Classification Rules",JSON.parse(res_cat)))
	  	next()
	  })
	next()
})
server.get('/taxonomy/rules/check/:', function (req, res, next) {
	res.send(packUpdate("OK","taxonomy","Check Rules Requested",_mode))
	RULE_Errors = 0
	checkRulesSeq()
	next()
})
server.get('/taxonomy/opml/:', function (req, res, next) {
	FS.readFile(_seats[_mode].opml_file_path(), 'utf8',  (err,opml_data) => {
		if (err)
			res.send(packUpdate("KO","OPML","Opml File Request",err))
		else{
			res.setHeader('Content-Type', 'text/xml');
			res.send(opml_data)
		}
	})
	next()
})
server.post('/taxonomy/opml/:', function (req, res, next, the_file) {
	backupOPML()
	FS.writeFile(_seats[_mode].opml_file_path(), req.params.data, function (err,data) {
		if (err)
			res.send(packUpdate("KO","OPML","Opml File Upload",err))
		else
			res.send(packUpdate("OK","OPML","Opml File Upload",_seats[_mode].opml_file_path()))
		next()
	})

	next()
})
server.get('/taxonomy/opml/check/:', function (req, res, next) {
	res.send(packUpdate("OK","opml","opml:check:start",_mode))
	loadOPML()
	checkOPMLIntegrity(0)
	next()
})

io.on('connection', function (socket) { //io.sockets.on()
	++_connetedUsers
	statusUpdate("OK","app","app:user:connected",_connetedUsers)

	socket.on('disconnect', function(){
		--_connetedUsers
    	statusUpdate("OK","app","app:user:disconnected",_connetedUsers)
  	});

  	socket.on('app:user:claim_access', function (name, fn) {
    	socket.broadcast.emit('app:user:access_claim');
    	fn('OK');
  	})
})



server.listen(_server_port, function () {
  console.log(server.name + ' ---> listening at ' + _server_port);
  setMode("_dev")
});

