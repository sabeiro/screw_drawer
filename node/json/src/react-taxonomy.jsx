var Button = ReactBootstrap.Button
var Panel = ReactBootstrap.Panel
var Nav = ReactBootstrap.Nav
var NavItem = ReactBootstrap.NavItem
var Jumbotron = ReactBootstrap.Jumbotron
var Pager = ReactBootstrap.Pager
var PageItem = ReactBootstrap.PageItem
var Input = ReactBootstrap.Input
var ButtonInput = ReactBootstrap.ButtonInput
var Label = ReactBootstrap.Label
var Table = ReactBootstrap.Table
var ProgressBar = ReactBootstrap.ProgressBar
var Badge = ReactBootstrap.Badge

var SequencePanel = React.createClass({
	getInitialState: function() {
		return {currentSeqItem: 0, canNext: true, canPrev: false, connected_users: 1, first_user: false, access_claim: false};
	},

	componentWillMount: function(){
		$.ajax({method: 'GET', url: '/app/users/', data: {}})
		.done(function( msg ) {
		    this.setState({connected_users: msg.details})
		}.bind(this));
		
		socket.on('app', this.updateConnectedUsers);
		socket.on('app:user:access_claim', this.handleClaimAccess);
	 },

	componentWillUnmount: function(){
		socket.removeListener('app', this.updateConnectedUsers);
		socket.removeListener('app:user:access_claim', this.handleClaimAccess);
	},

	updateConnectedUsers: function(msg){
		if(msg.description.indexOf("app:user") == 0)
			this.setState({connected_users: msg.details})

		
		if(!this.state.first_user && msg.details == 1)
			this.setState({first_user: true, currentSeqItem: 1})
	},

	handleClaimAccess: function(msg){
		this.setState({access_claim: true})
		window.setTimeout(this.dismissClaim, 10000)
	},

	dismissClaim: function(){
		this.setState({access_claim: false})
	},

	changeCurrentSeqItem: function(e){
		var seqSelection = this.state.currentSeqItem + e

		if(seqSelection <= 0)  seqSelection = 1;
		if(seqSelection > this.props.numCards) seqSelection = this.props.numCards;

		this.setState({currentSeqItem: seqSelection});
	},

	changePrevNext: function(prev,next){
		this.setState({canNext: next, canPrev:prev});
	},

	changeMode: function(mode){
		this.setState({mode: mode});
	},

	render: function() {
		//console.log("CLAIMED IN RENDER? " + this.state.access_claim)
		var title_arrow = this.state.first_user ? <span className="glyphicon glyphicon-menu-right" aria-hidden="true"></span> : <span></span>
		var titleStyle = this.state.access_claim ? "panel panel-danger" : "panel panel-primary"
		var titleText = this.state.access_claim ? "  A USER CLAIMED ACCESS TO THE APPLICATION" : "TAXONOMY MANAGER"
		var titleIcon = this.state.access_claim ? <span className="glyphicon glyphicon-warning-sign warningIcon"></span> : ""

		var title = (
			<div className="row">
			  <div className="col-md-7">{titleIcon} {titleText}</div>
			  <div className="col-md-3 text-right">{title_arrow} <ModeTitleLabel modes={this.props.modes} mode={this.state.mode}/></div>
			  <div className="col-md-2 text-right"><span className="glyphicon glyphicon-user" aria-hidden="true"></span> {this.state.connected_users}</div>
	  		</div>
		)

		return (
			<Panel header={title} bsStyle="primary" className={titleStyle} claim={this.state.access_claim}>
			<SequenceTabs currentSeqItem={this.state.currentSeqItem}/>
		  	<CardContainer connected_users={this.state.connected_users} currentSeqItem={this.state.currentSeqItem} changePrevNext={this.changePrevNext} modes={this.props.modes} current_mode={this.state.mode} changeMode={this.changeMode} first_user={this.state.first_user}/>
		  	<CardPager currentSeqItem={this.state.currentSeqItem} changeCurrentSeqItem={this.changeCurrentSeqItem} canPrev={this.state.canPrev} canNext={this.state.canNext}/>
			</Panel>
		);
  }
});

var ModeTitleLabel = React.createClass({
  getModeLabel: function(){
		for(var a=0; a<this.props.modes.length; a++){
			if(this.props.modes[a].value == this.props.mode)
				return this.props.modes[a].label
		}
	},
  render: function() {
    return (
    	 <span>{this.getModeLabel()}</span>
    );
  }
});

var SequenceTabs = React.createClass({
  getInitialState: function() {
    return {};
  },

  handleSelect: function(selectedKey) {
  	alert('selected ' + selectedKey);
  },

  isDisabled: function(current_pill){
  	return current_pill == this.props.currentSeq ? false : true;
  },

  render: function() {
    return (
    	<Nav bsStyle="pills" activeKey={this.props.currentSeqItem} onSelect={this.handleSelect}>
		    <NavItem eventKey={1} disabled={this.isDisabled(1)}>Select Mode</NavItem>
		    <NavItem eventKey={2} disabled={this.isDisabled(2)}>Upload OPML</NavItem>
		    <NavItem eventKey={3} disabled={this.isDisabled(3)}>Verify OPML</NavItem>
		    <NavItem eventKey={4} disabled={this.isDisabled(4)}>Update Taxonomy</NavItem>
		    <NavItem eventKey={5} disabled={this.isDisabled(4)}>Download OPML</NavItem>
  		</Nav>
    );
  }
});

var CardContainer = React.createClass({
  getInitialState: function() {
    return {};
  },

  render: function() {
  	var card2Display;
	if(!this.props.first_user){
		card2Display = card2Display = <CardWelcome changePrevNext={this.props.changePrevNext} connected_users={this.props.connected_users}/>
	}
	else{
		switch(this.props.currentSeqItem){
		 	case 1:
		 		card2Display = <CardSelectMode changePrevNext={this.props.changePrevNext} modes={this.props.modes} current_mode={this.props.current_mode} changeMode={this.props.changeMode}/>
		 		break;
		 	case 2:
		 		card2Display = <CardUploadOPML changePrevNext={this.props.changePrevNext} current_mode={this.props.current_mode}/>
		 		break;
		 	case 3:
		 		card2Display = <CardVerifydOPML changePrevNext={this.props.changePrevNext}/>
		 		break;
		 	case 4:
		 		card2Display = <CardUpdateTaxonomy changePrevNext={this.props.changePrevNext}/>
		 		break;
		 	case 5:
		 		card2Display = <CardDownloadOPML changePrevNext={this.props.changePrevNext} current_mode={this.props.current_mode}/>
		 		break;
		}
	}
	
    return (
    	<div className="card">
    	 	<div className="card-height-indicator"></div>
	    	 <div className="card-content">
	    	 	<div className="card-body">
			    	{card2Display}
		    	 </div>
	    	 </div>
    	 </div>
    );
  }
});

var CardPager = React.createClass({
  getInitialState: function() {
    return {};
  },

  scrollCard: function(e){
  	if( (e == -1 && this.props.canPrev) || (e == 1 && this.props.canNext))
  		this.props.changeCurrentSeqItem(e)
  },

  render: function() {
    return (
    	<Pager>
		    <PageItem previous title="prev" disabled={!this.props.canPrev} onMouseUp={this.scrollCard.bind(this, -1)} >
		    	<span className="glyphicon glyphicon-chevron-left" aria-hidden="true"></span> 
		    	  Previous
		    </PageItem>
		    <PageItem next title="next" disabled={!this.props.canNext} onMouseUp={this.scrollCard.bind(this, +1)}  href="#">
			    Next   
			    <span className="glyphicon glyphicon-chevron-right" aria-hidden="true"></span>
		    </PageItem>
  		</Pager>
    );
  }
}); 


var CardWelcome = React.createClass({
	getInitialState: function() {
    	return {access_claimed: false};
  	},

	componentWillMount: function(){
		this.props.changePrevNext(false,false)
	},

	handleClaim: function(){
		if(this.state.access_claimed)
			return

		socket.emit('app:user:claim_access', '', function (data) {
	      this.setState({access_claimed: true})
	    }.bind(this));
	},

	render: function(){
		var btnText = this.state.access_claimed ? "Access Claimed" : "Claim Access"
		var btnStyle = this.state.access_claimed ? "btn-raised btn-success" : "btn-raised default"

		return(
			<Jumbotron>
		    <h1>Simultaneous Access Not Permitted</h1>
		    <p>This App can be accessed by one person per time. Please claim your access to ask all connected users to disconnect.</p>
		    
		    	
		    <div className="container-fluid">
		    	<div className="row">
		    		<div className="col-md-4"></div>
				  	<div className="col-md-4 text-center">
				  		<span id="user_count_claim" className="glyphicon glyphicon-flash" aria-hidden="true"></span>
				  		<br/>
				  		<Button className={btnStyle} onClick={this.handleClaim}>{btnText}</Button>
				  	</div>
				  	<div className="col-md-4"></div>
		    	</div>
		    </div>
  		</Jumbotron>

			
		);
	}
})


var CardSelectMode = React.createClass({
  getInitialState: function() {
    return {canNext: true, canPrev: false};
  },

  componentWillMount: function(){
	this.props.changePrevNext(this.state.canPrev, this.state.canNext)
	$.ajax({method: 'GET', url: '/app/mode/', data: {}})
		.done(function( msg ) {
		    this.props.changeMode(msg.details)
		}.bind(this));
  },

  handleModeChange: function(e){
  	this.setState({current_mode: e.target.value})

  	$.ajax({method: 'PUT', url: '/app/mode/', data: {the_mode:e.target.value}})
		.done(function( msg ) {
		    this.props.changeMode(this.state.current_mode)
		}.bind(this));
  },

  render: function() {
  	var modeNodes = this.props.modes.map(function(the_mode) {
  	 	var isSelected = the_mode.value == this.props.current_mode ? true : false;
	    return (
	    	<option value={the_mode.value} key={the_mode.value} selected={isSelected}>{the_mode.label}</option> //selected={isSelected}
	    );
    }.bind(this));

    return (
    	 <Jumbotron>
		    <h1>Choose Mode</h1>
		    <p>This is a simple hero unit, a simple jumbotron-style component for calling extra attention to featured content or information.</p>
		    
		    	
		    <div className="container-fluid">
		    	<div className="row">
		    		<div className="col-md-4"></div>
				  	<div className="col-md-4">
				  		<Input type="select" label="Working Mode" onChange={this.handleModeChange} defaultValue={this.props.current_mode}>
					      {modeNodes}
					    </Input>	
				  	</div>
				  	<div className="col-md-4"></div>
		    	</div>
		    </div>
  		</Jumbotron>
    );
  }
});

var CardUploadOPML = React.createClass({
  getInitialState: function() {
    return {canNext: true, canPrev: true, file2Upload: null, fileUploaded: false, fileUploadble: false};
  },

componentWillMount: function(){
	this.props.changePrevNext(this.state.canPrev, this.state.canNext)
},

handleSubmit: function(e){
	e.preventDefault();
	var reader = new FileReader();
	reader.readAsText(this.state.file2Upload, 'UTF-8');
	reader.onload = this.shipOff;
	return false;
},

shipOff: function(event) {
    var result = event.target.result;
    var fileName = document.getElementById('fileBox').files[0].name; 

    this.setState({fileUploaded: true}); // -----> to DELETE

    $.post('/taxonomy/opml/', { data: result, name: fileName }).done(function( msg ) {
	    console.log(msg);
	    this.setState({fileUploaded: true});
	});
},


handleFileChange: function(e){
	if(document.getElementById('fileBox').files[0].name.indexOf(this.props.current_mode) > 0)
		this.setState({file2Upload: document.getElementById('fileBox').files[0], fileUploaded: false, fileUploadble: true});
	else
		this.setState({fileUploadable: false})
},

handleClickOnFileUpload: function(e){
	$('#fileBox').click()  // Trick to show file dialog
},

  render: function() {
  	var placeHolder = "Choose taxonomy" + this.props.current_mode + ".opml file..."
  	if(this.state.file2Upload)
  		placeHolder = this.state.file2Upload.name
  	
  	var btnStyle = this.state.fileUploaded ?  "btn btn-raised btn-success" : "btn btn-raised btn-default"
  	var btnText = this.state.fileUploaded ?  "UPLOADED!" : "Upload"

    return (
		<Jumbotron>
		    <h1>Upload OPML</h1>
		    <p>This is a simple hero unit, a simple jumbotron-style component for calling extra attention to featured content or information.</p>
		    <form onSubmit={this.handleSubmit}>
		    <div className="container-fluid">
		    	<div className="row">
		    		<div className="col-md-2"></div>
				  	<div className="col-md-5">
				  		<Input type="text"  readOnly className="form-control" id="fileBoxFileName" placeholder={placeHolder} onClick={this.handleClickOnFileUpload}/>
					 	<Input type="file" name="fileToUpload" id="fileBox"  onChange={this.handleFileChange} />
				  	</div>
				  	<div className="col-md-3"><ButtonInput type="submit" id="fileBoxSubmitBtn" className={btnStyle}>{btnText}</ButtonInput></div>
				  	<div className="col-md-2"></div>
		    	</div>
		    </div>
		    </form>
  		</Jumbotron>
    );
  }
});

var CardVerifydOPML = React.createClass({
  getInitialState: function() {
    return {canNext: false, canPrev: true, messages:[], progress_min: 0, progress_max: 1, errors:0, verified:false};
  },

	componentWillMount: function(){
		this.props.changePrevNext(this.state.canPrev, this.state.canNext)
	},

	componentDidMount: function(){
		socket.on('opml', this.handleOPMLCheckEmit);
	},

	componentWillUnmount: function(){
		socket.removeListener('opml', this.handleOPMLCheckEmit);
	},

	handleOPMLCheckEmit: function(msg){
    		console.log(msg.description)
    		//console.log(msg)
		if(msg.status == "KO" && msg.description != 'opml:check:completed'){ // 
			var newErrors = this.state.messages
			newErrors.push(msg)
			this.setState({messages: newErrors})
		}
		if(msg.description == 'opml:check:completed'){
			if(msg.status == 'KO'){
				this.setState({canNext: false, canPrev: true})
				this.props.changePrevNext(true, false)
			}else{
				this.setState({canNext: true, canPrev: true})
				this.props.changePrevNext(true, true)
			}
		} 
		if(msg.description == 'opml:check:category'){
			this.setState({progress_min: msg.details.current + 1, progress_max: msg.details.total})
		}
		if(msg.description == 'opml:check:completed'){
			console.log(msg)
			this.setState({errors: msg.details, verified:true})
		}
  	},


	handleVerifyOPML: function(){
		this.setState({messages: [],canNext: false, canPrev: false, progress_max:0, progress_min:0, verified: false})
		this.forceUpdate(function(){
			this.props.changePrevNext(false, false)
		 	$.ajax({method: 'GET', url: '/taxonomy/opml/check/', data: {}})
				.done(function( msg ) {
					//
				}.bind(this));
		}.bind(this))
 	},

  render: function() {
	var btnStyle = 'btn btn-raised'
	if(this.state.verified){
		if(this.state.errors == 0)
			btnStyle += ' btn-success'
		else
			btnStyle += ' btn-warning'
	}

	var progressStyle = ''
	if(this.state.verified){
		if(this.state.errors == 0)
			progressStyle += 'progress-bar-success'
		else
			progressStyle += 'progress-bar-warning'
	}

	var btnLabel = "Verify OMPL"
	if(this.state.verified){
		if(this.state.errors == 0)
			btnLabel = 'OPML Verified'
		else
			btnLabel = 'OPML ERROR '
	}

	var badgeError = (this.state.verified && this.state.errors > 0) ? <Badge>{this.state.errors}</Badge> : <span></span>
    return (
    	 <Jumbotron>
		    <h1>Verify OPML</h1>
		    <p>This is a simple hero unit, a simple jumbotron-style component for calling extra attention to featured content or information.</p>		    
		    <div className="container-fluid">
		    	<div className="row">
		    		<div className="col-md-4">
		    			<Button bsStyle="default" className={btnStyle} onClick={this.handleVerifyOPML}>{btnLabel} {badgeError}</Button>
		    		</div>
				  	<div className="col-md-8">
				  		<div>
						 	<UpdateProgressBar min={this.state.progress_min} max={this.state.progress_max} barStyle={progressStyle}/>
						</div>
				  	</div>
		    	</div>
		    </div>

		    <OPMLErrorPane messages={this.state.messages}/>
  		</Jumbotron>
    );
  }
});

// ProgressBar
var UpdateProgressBar = React.createClass({
	render: function() {
		var perc = Math.floor((this.props.min/this.props.max) * 100)

		return (
	    	<ProgressBar id="updateProgressBar" className={this.props.barStyle} now={perc} label="%(percent)s%" />
	    )
	}
});

var OPMLErrorPane = React.createClass({
	render: function() {
		//console.log("RENDER ERROR PANE "  + this.props.messages.length)
		var errorMessages = this.props.messages.map(function(message, i) {
		    return (
		    	<tr key={i}><td>{i+1}</td><td>{message.details.category}</td> <td>{message.details.rule}</td> <td>{message.details.detail}</td> </tr>
		    );
	    }.bind(this));
		var table_head = this.props.messages.length > 0 ? (<thead> <tr><th>#</th><th>Category</th> <th>Rule</th> <th>Description</th> </tr> </thead>) : <thead></thead>//(<thead> <tr><th></th><th></th> <th></th> <th></th> </tr> </thead>)
	    return (
	    	<div id="verifyOPMLErrorTable">
			    <Table className="table">
					{table_head}
					<tbody>
						{errorMessages}
					</tbody>
				</Table>
			</div>
	    )
	}
});


var CardUpdateTaxonomy = React.createClass({
	getInitialState: function() {
		return {canNext: false, canPrev: true, currentJob: '', currentNode: '', progress_max:0, progress_min:0, updated: false};
	},

	componentWillMount: function(){
		this.props.changePrevNext(this.state.canPrev, this.state.canNext)
		socket.on('taxonomy', this.dispatchMessages);
	},

	componentWillUnmount: function(){
		socket.removeListener('taxonomy', this.dispatchMessages);
	},

	handdleUdateTaxonomy: function(){
		if(this.state.currentJob.length > 0)
			return

		this.setState({canNext: false, canPrev: false, updated: false, currentJob:'', currentNode:'', progress_max:0, progress_min:0})
		this.props.changePrevNext(this.state.canPrev, this.state.canNext)

		$.ajax({method: 'PUT', url: '/taxonomy/', data: {}})
			.done(function( msg ) {
			    //
			}.bind(this));
	},

	dispatchMessages: function(msg){
		// PROCESS START -> END
		if(msg.description == "taxonomy:update:started")
			this.setState({currentJob: "Starting Taxonomy Update", currentNode:''})
		if(msg.description == "taxonomy:update:ended"){
			this.setState({currentJob: '', currentNode:'',progress_max:0, progress_min:0, updated: true, canNext: true, canPrev: true})
			this.props.changePrevNext(this.state.canPrev, this.state.canNext)
		}

		// READ DATA
		if(msg.description == "taxonomy:read:opml")
			this.setState({currentJob: "OPML Readed"})
		if(msg.description == "taxonomy:categories:loaded")
			this.setState({currentJob: "DMP Categories Loaded"})
		if(msg.description == "taxonomy:rules:loaded")
			this.setState({currentJob: "DMP Rules Loaded"})
		if(msg.description == "taxonomy:update:opml")
			this.setState({currentJob: "OPML Updated"})
		

		// TAXONOMY CATEGORIES
		if(msg.description == "taxonomy:delete:categories:limbo")
			this.setState({currentJob: "Deleting LIMBO Categories"})
		if(msg.description == "taxonomy:update:categories:started")
			this.setState({currentJob: "Updating Taxonomy Categories", progress_max:0, progress_min:0})
		if(msg.description == "taxonomy:update:category")
			this.setState({progress_max:msg.details.total, progress_min:msg.details.current, currentNode: "Updating Category: " + msg.details.category.name + " [ID:" + msg.details.category.id  + "]"})
		
		// TAXONOMY RULES
		if(msg.description == "taxonomy:update:rules:started")
			this.setState({currentJob: "Updating Taxonomy Rules", currentNode:'', progress_max:0, progress_min:0})
		if(msg.description == "taxonomy:update:rule")
			this.setState({progress_max:msg.details.total, progress_min:msg.details.current, currentNode: "Updating Rule: " + msg.details.rule.name + " [ID:" + msg.details.rule.id  + "]"})
	},

	render: function() {
		var counter = this.state.progress_min > 0 ? <span>{this.state.progress_min}/{this.state.progress_max}</span> : <span></span>
		var btnText = this.state.updated ? "TAXONOMY UPDATED" : "UPDATE TAXONOMY"
		var btnStyle = this.state.updated ? "btn-raised btn-success" : "btn-raised btn-default"
		var progressStyle = this.state.updated? 'progress-bar-success' : ''
		var spinning = this.state.currentJob.length > 0 ? <span className="glyphicon glyphicon-refresh spin"></span> : <span></span>

		return (
			 <Jumbotron>
			    <h1>Update Taxonomy</h1>
			    <p>This is a simple hero unit, a simple jumbotron-style component for calling extra attention to featured content or information.</p>
			    <div className="container-fluid">
			    	<div className="row">
			    		<div className="col-md-4">
			    			<Button className={btnStyle} onClick={this.handdleUdateTaxonomy}>{btnText} {spinning}</Button>
			    		</div>
					  	<div className="col-md-8">
					  		<h3>{this.state.currentJob} {counter}</h3>
						    <p><UpdateProgressBar min={this.state.progress_min} max={this.state.progress_max} barStyle={progressStyle}/></p>
						    <p id="taxonomy_job_node">{this.state.currentNode}</p>
					  	</div>
			    	</div>
			    </div>
			</Jumbotron>
		);
	}
});


var CardDownloadOPML = React.createClass({
  getInitialState: function() {
    return {canNext: false, canPrev: true, opmlFileHref:''};
  },

  componentWillMount: function(){
	this.props.changePrevNext(this.state.canPrev, this.state.canNext)
  },

  componentDidMount: function(){
  	//var url = URL.createObjectURL(result);
  	
  	$.ajax({method: 'GET', url: '/taxonomy/opml/', 'xhrFields' : {'responseType' : 'blob'},'dataType' : 'binary', processData: false})
		.done(function( msg ) {
		    //var url = URL.createObjectURL(msg)
		    //$("a").attr("href", url)
		    console.log(msg)
		    this.setState({opmlFileHref: URL.createObjectURL(msg)})
		    console.log(url)
		}.bind(this));
	},


  render: function() {
  	var opmlFileName = 'taxonomy' + this.props.current_mode + '.opml'
    return (
    	 <Jumbotron>
		    <h1>Download OPML</h1>
		    <p>This is a simple hero unit, a simple jumbotron-style component for calling extra attention to featured content or information.</p>
		    
		    	
		    <div className="container-fluid">
		    	<div className="row">
		    		<div className="col-md-4"></div>
				  	<div className="col-md-4">
				  		<a href={this.state.opmlFileHref} id="downloadOPMLLink" download={opmlFileName}>DownloadOPML</a>  <span id="iconDonwloadOPML" className='glyphicon glyphicon-cloud-download'></span>
				  	</div>
				  	<div className="col-md-4"></div>
		    	</div>
		    </div>
  		</Jumbotron>
    );
  }
});

ReactDOM.render(
  <SequencePanel numCards={5} modes={[{value: "_dev", label: "Development"},{value: "_prod", label: "Production"}]}/>,
  document.getElementById('reactMountingNode')
);

