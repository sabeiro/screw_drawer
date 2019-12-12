'use strict';

var Button = ReactBootstrap.Button;
var Panel = ReactBootstrap.Panel;
var Nav = ReactBootstrap.Nav;
var NavItem = ReactBootstrap.NavItem;
var Jumbotron = ReactBootstrap.Jumbotron;
var Pager = ReactBootstrap.Pager;
var PageItem = ReactBootstrap.PageItem;
var Input = ReactBootstrap.Input;
var ButtonInput = ReactBootstrap.ButtonInput;
var Label = ReactBootstrap.Label;
var Table = ReactBootstrap.Table;
var ProgressBar = ReactBootstrap.ProgressBar;
var Badge = ReactBootstrap.Badge;

var SequencePanel = React.createClass({
	getInitialState: function getInitialState() {
		return { currentSeqItem: 0, canNext: true, canPrev: false, connected_users: 1, first_user: false, access_claim: false };
	},

	componentWillMount: function componentWillMount() {
		$.ajax({ method: 'GET', url: '/app/users/', data: {} }).done(function (msg) {
			this.setState({ connected_users: msg.details });
		}.bind(this));

		socket.on('app', this.updateConnectedUsers);
		socket.on('app:user:access_claim', this.handleClaimAccess);
	},

	componentWillUnmount: function componentWillUnmount() {
		socket.removeListener('app', this.updateConnectedUsers);
		socket.removeListener('app:user:access_claim', this.handleClaimAccess);
	},

	updateConnectedUsers: function updateConnectedUsers(msg) {
		if (msg.description.indexOf("app:user") == 0) this.setState({ connected_users: msg.details });

		if (!this.state.first_user && msg.details == 1) this.setState({ first_user: true, currentSeqItem: 1 });
	},

	handleClaimAccess: function handleClaimAccess(msg) {
		this.setState({ access_claim: true });
		window.setTimeout(this.dismissClaim, 10000);
	},

	dismissClaim: function dismissClaim() {
		this.setState({ access_claim: false });
	},

	changeCurrentSeqItem: function changeCurrentSeqItem(e) {
		var seqSelection = this.state.currentSeqItem + e;

		if (seqSelection <= 0) seqSelection = 1;
		if (seqSelection > this.props.numCards) seqSelection = this.props.numCards;

		this.setState({ currentSeqItem: seqSelection });
	},

	changePrevNext: function changePrevNext(prev, next) {
		this.setState({ canNext: next, canPrev: prev });
	},

	changeMode: function changeMode(mode) {
		this.setState({ mode: mode });
	},

	render: function render() {
		//console.log("CLAIMED IN RENDER? " + this.state.access_claim)
		var title_arrow = this.state.first_user ? React.createElement('span', { className: 'glyphicon glyphicon-menu-right', 'aria-hidden': 'true' }) : React.createElement('span', null);
		var titleStyle = this.state.access_claim ? "panel panel-danger" : "panel panel-primary";
		var titleText = this.state.access_claim ? "  A USER CLAIMED ACCESS TO THE APPLICATION" : "TAXONOMY MANAGER";
		var titleIcon = this.state.access_claim ? React.createElement('span', { className: 'glyphicon glyphicon-warning-sign warningIcon' }) : "";

		var title = React.createElement(
			'div',
			{ className: 'row' },
			React.createElement(
				'div',
				{ className: 'col-md-7' },
				titleIcon,
				' ',
				titleText
			),
			React.createElement(
				'div',
				{ className: 'col-md-3 text-right' },
				title_arrow,
				' ',
				React.createElement(ModeTitleLabel, { modes: this.props.modes, mode: this.state.mode })
			),
			React.createElement(
				'div',
				{ className: 'col-md-2 text-right' },
				React.createElement('span', { className: 'glyphicon glyphicon-user', 'aria-hidden': 'true' }),
				' ',
				this.state.connected_users
			)
		);

		return React.createElement(
			Panel,
			{ header: title, bsStyle: 'primary', className: titleStyle, claim: this.state.access_claim },
			React.createElement(SequenceTabs, { currentSeqItem: this.state.currentSeqItem }),
			React.createElement(CardContainer, { connected_users: this.state.connected_users, currentSeqItem: this.state.currentSeqItem, changePrevNext: this.changePrevNext, modes: this.props.modes, current_mode: this.state.mode, changeMode: this.changeMode, first_user: this.state.first_user }),
			React.createElement(CardPager, { currentSeqItem: this.state.currentSeqItem, changeCurrentSeqItem: this.changeCurrentSeqItem, canPrev: this.state.canPrev, canNext: this.state.canNext })
		);
	}
});

var ModeTitleLabel = React.createClass({
	getModeLabel: function getModeLabel() {
		for (var a = 0; a < this.props.modes.length; a++) {
			if (this.props.modes[a].value == this.props.mode) return this.props.modes[a].label;
		}
	},
	render: function render() {
		return React.createElement(
			'span',
			null,
			this.getModeLabel()
		);
	}
});

var SequenceTabs = React.createClass({
	getInitialState: function getInitialState() {
		return {};
	},

	handleSelect: function handleSelect(selectedKey) {
		alert('selected ' + selectedKey);
	},

	isDisabled: function isDisabled(current_pill) {
		return current_pill == this.props.currentSeq ? false : true;
	},

	render: function render() {
		return React.createElement(
			Nav,
			{ bsStyle: 'pills', activeKey: this.props.currentSeqItem, onSelect: this.handleSelect },
			React.createElement(
				NavItem,
				{ eventKey: 1, disabled: this.isDisabled(1) },
				'Select Mode'
			),
			React.createElement(
				NavItem,
				{ eventKey: 2, disabled: this.isDisabled(2) },
				'Upload OPML'
			),
			React.createElement(
				NavItem,
				{ eventKey: 3, disabled: this.isDisabled(3) },
				'Verify OPML'
			),
			React.createElement(
				NavItem,
				{ eventKey: 4, disabled: this.isDisabled(4) },
				'Update Taxonomy'
			),
			React.createElement(
				NavItem,
				{ eventKey: 5, disabled: this.isDisabled(4) },
				'Download OPML'
			)
		);
	}
});

var CardContainer = React.createClass({
	getInitialState: function getInitialState() {
		return {};
	},

	render: function render() {
		var card2Display;
		if (!this.props.first_user) {
			card2Display = card2Display = React.createElement(CardWelcome, { changePrevNext: this.props.changePrevNext, connected_users: this.props.connected_users });
		} else {
			switch (this.props.currentSeqItem) {
				case 1:
					card2Display = React.createElement(CardSelectMode, { changePrevNext: this.props.changePrevNext, modes: this.props.modes, current_mode: this.props.current_mode, changeMode: this.props.changeMode });
					break;
				case 2:
					card2Display = React.createElement(CardUploadOPML, { changePrevNext: this.props.changePrevNext, current_mode: this.props.current_mode });
					break;
				case 3:
					card2Display = React.createElement(CardVerifydOPML, { changePrevNext: this.props.changePrevNext });
					break;
				case 4:
					card2Display = React.createElement(CardUpdateTaxonomy, { changePrevNext: this.props.changePrevNext });
					break;
				case 5:
					card2Display = React.createElement(CardDownloadOPML, { changePrevNext: this.props.changePrevNext, current_mode: this.props.current_mode });
					break;
			}
		}

		return React.createElement(
			'div',
			{ className: 'card' },
			React.createElement('div', { className: 'card-height-indicator' }),
			React.createElement(
				'div',
				{ className: 'card-content' },
				React.createElement(
					'div',
					{ className: 'card-body' },
					card2Display
				)
			)
		);
	}
});

var CardPager = React.createClass({
	getInitialState: function getInitialState() {
		return {};
	},

	scrollCard: function scrollCard(e) {
		if (e == -1 && this.props.canPrev || e == 1 && this.props.canNext) this.props.changeCurrentSeqItem(e);
	},

	render: function render() {
		return React.createElement(
			Pager,
			null,
			React.createElement(
				PageItem,
				{ previous: true, title: 'prev', disabled: !this.props.canPrev, onMouseUp: this.scrollCard.bind(this, -1) },
				React.createElement('span', { className: 'glyphicon glyphicon-chevron-left', 'aria-hidden': 'true' }),
				'Previous'
			),
			React.createElement(
				PageItem,
				{ next: true, title: 'next', disabled: !this.props.canNext, onMouseUp: this.scrollCard.bind(this, +1), href: '#' },
				'Next',
				React.createElement('span', { className: 'glyphicon glyphicon-chevron-right', 'aria-hidden': 'true' })
			)
		);
	}
});

var CardWelcome = React.createClass({
	getInitialState: function getInitialState() {
		return { access_claimed: false };
	},

	componentWillMount: function componentWillMount() {
		this.props.changePrevNext(false, false);
	},

	handleClaim: function handleClaim() {
		if (this.state.access_claimed) return;

		socket.emit('app:user:claim_access', '', function (data) {
			this.setState({ access_claimed: true });
		}.bind(this));
	},

	render: function render() {
		var btnText = this.state.access_claimed ? "Access Claimed" : "Claim Access";
		var btnStyle = this.state.access_claimed ? "btn-raised btn-success" : "btn-raised default";

		return React.createElement(
			Jumbotron,
			null,
			React.createElement(
				'h1',
				null,
				'Simultaneous Access Not Permitted'
			),
			React.createElement(
				'p',
				null,
				'This App can be accessed by one person per time. Please claim your access to ask all connected users to disconnect.'
			),
			React.createElement(
				'div',
				{ className: 'container-fluid' },
				React.createElement(
					'div',
					{ className: 'row' },
					React.createElement('div', { className: 'col-md-4' }),
					React.createElement(
						'div',
						{ className: 'col-md-4 text-center' },
						React.createElement('span', { id: 'user_count_claim', className: 'glyphicon glyphicon-flash', 'aria-hidden': 'true' }),
						React.createElement('br', null),
						React.createElement(
							Button,
							{ className: btnStyle, onClick: this.handleClaim },
							btnText
						)
					),
					React.createElement('div', { className: 'col-md-4' })
				)
			)
		);
	}
});

var CardSelectMode = React.createClass({
	getInitialState: function getInitialState() {
		return { canNext: true, canPrev: false };
	},

	componentWillMount: function componentWillMount() {
		this.props.changePrevNext(this.state.canPrev, this.state.canNext);
		$.ajax({ method: 'GET', url: '/app/mode/', data: {} }).done(function (msg) {
			this.props.changeMode(msg.details);
		}.bind(this));
	},

	handleModeChange: function handleModeChange(e) {
		this.setState({ current_mode: e.target.value });

		$.ajax({ method: 'PUT', url: '/app/mode/', data: { the_mode: e.target.value } }).done(function (msg) {
			this.props.changeMode(this.state.current_mode);
		}.bind(this));
	},

	render: function render() {
		var modeNodes = this.props.modes.map(function (the_mode) {
			var isSelected = the_mode.value == this.props.current_mode ? true : false;
			return React.createElement(
				'option',
				{ value: the_mode.value, key: the_mode.value, selected: isSelected },
				the_mode.label
			) //selected={isSelected}
			;
		}.bind(this));

		return React.createElement(
			Jumbotron,
			null,
			React.createElement(
				'h1',
				null,
				'Choose Mode'
			),
			React.createElement(
				'p',
				null,
				'This is a simple hero unit, a simple jumbotron-style component for calling extra attention to featured content or information.'
			),
			React.createElement(
				'div',
				{ className: 'container-fluid' },
				React.createElement(
					'div',
					{ className: 'row' },
					React.createElement('div', { className: 'col-md-4' }),
					React.createElement(
						'div',
						{ className: 'col-md-4' },
						React.createElement(
							Input,
							{ type: 'select', label: 'Working Mode', onChange: this.handleModeChange, defaultValue: this.props.current_mode },
							modeNodes
						)
					),
					React.createElement('div', { className: 'col-md-4' })
				)
			)
		);
	}
});

var CardUploadOPML = React.createClass({
	getInitialState: function getInitialState() {
		return { canNext: true, canPrev: true, file2Upload: null, fileUploaded: false, fileUploadble: false };
	},

	componentWillMount: function componentWillMount() {
		this.props.changePrevNext(this.state.canPrev, this.state.canNext);
	},

	handleSubmit: function handleSubmit(e) {
		e.preventDefault();
		var reader = new FileReader();
		reader.readAsText(this.state.file2Upload, 'UTF-8');
		reader.onload = this.shipOff;
		return false;
	},

	shipOff: function shipOff(event) {
		var result = event.target.result;
		var fileName = document.getElementById('fileBox').files[0].name;

		this.setState({ fileUploaded: true }); // -----> to DELETE

		$.post('/taxonomy/opml/', { data: result, name: fileName }).done(function (msg) {
			console.log(msg);
			this.setState({ fileUploaded: true });
		});
	},

	handleFileChange: function handleFileChange(e) {
		if (document.getElementById('fileBox').files[0].name.indexOf(this.props.current_mode) > 0) this.setState({ file2Upload: document.getElementById('fileBox').files[0], fileUploaded: false, fileUploadble: true });else this.setState({ fileUploadable: false });
	},

	handleClickOnFileUpload: function handleClickOnFileUpload(e) {
		$('#fileBox').click(); // Trick to show file dialog
	},

	render: function render() {
		var placeHolder = "Choose taxonomy" + this.props.current_mode + ".opml file...";
		if (this.state.file2Upload) placeHolder = this.state.file2Upload.name;

		var btnStyle = this.state.fileUploaded ? "btn btn-raised btn-success" : "btn btn-raised btn-default";
		var btnText = this.state.fileUploaded ? "UPLOADED!" : "Upload";

		return React.createElement(
			Jumbotron,
			null,
			React.createElement(
				'h1',
				null,
				'Upload OPML'
			),
			React.createElement(
				'p',
				null,
				'This is a simple hero unit, a simple jumbotron-style component for calling extra attention to featured content or information.'
			),
			React.createElement(
				'form',
				{ onSubmit: this.handleSubmit },
				React.createElement(
					'div',
					{ className: 'container-fluid' },
					React.createElement(
						'div',
						{ className: 'row' },
						React.createElement('div', { className: 'col-md-2' }),
						React.createElement(
							'div',
							{ className: 'col-md-5' },
							React.createElement(Input, { type: 'text', readOnly: true, className: 'form-control', id: 'fileBoxFileName', placeholder: placeHolder, onClick: this.handleClickOnFileUpload }),
							React.createElement(Input, { type: 'file', name: 'fileToUpload', id: 'fileBox', onChange: this.handleFileChange })
						),
						React.createElement(
							'div',
							{ className: 'col-md-3' },
							React.createElement(
								ButtonInput,
								{ type: 'submit', id: 'fileBoxSubmitBtn', className: btnStyle },
								btnText
							)
						),
						React.createElement('div', { className: 'col-md-2' })
					)
				)
			)
		);
	}
});

var CardVerifydOPML = React.createClass({
	getInitialState: function getInitialState() {
		return { canNext: false, canPrev: true, messages: [], progress_min: 0, progress_max: 1, errors: 0, verified: false };
	},

	componentWillMount: function componentWillMount() {
		this.props.changePrevNext(this.state.canPrev, this.state.canNext);
	},

	componentDidMount: function componentDidMount() {
		socket.on('opml', this.handleOPMLCheckEmit);
	},

	componentWillUnmount: function componentWillUnmount() {
		socket.removeListener('opml', this.handleOPMLCheckEmit);
	},

	handleOPMLCheckEmit: function handleOPMLCheckEmit(msg) {
		console.log(msg.description);
		//console.log(msg)
		if (msg.status == "KO" && msg.description != 'opml:check:completed') {
			//
			var newErrors = this.state.messages;
			newErrors.push(msg);
			this.setState({ messages: newErrors });
		}
		if (msg.description == 'opml:check:completed') {
			if (msg.status == 'KO') {
				this.setState({ canNext: false, canPrev: true });
				this.props.changePrevNext(true, false);
			} else {
				this.setState({ canNext: true, canPrev: true });
				this.props.changePrevNext(true, true);
			}
		}
		if (msg.description == 'opml:check:category') {
			this.setState({ progress_min: msg.details.current + 1, progress_max: msg.details.total });
		}
		if (msg.description == 'opml:check:completed') {
			console.log(msg);
			this.setState({ errors: msg.details, verified: true });
		}
	},

	handleVerifyOPML: function handleVerifyOPML() {
		this.setState({ messages: [], canNext: false, canPrev: false, progress_max: 0, progress_min: 0, verified: false });
		this.forceUpdate(function () {
			this.props.changePrevNext(false, false);
			$.ajax({ method: 'GET', url: '/taxonomy/opml/check/', data: {} }).done(function (msg) {
				//
			}.bind(this));
		}.bind(this));
	},

	render: function render() {
		var btnStyle = 'btn btn-raised';
		if (this.state.verified) {
			if (this.state.errors == 0) btnStyle += ' btn-success';else btnStyle += ' btn-warning';
		}

		var progressStyle = '';
		if (this.state.verified) {
			if (this.state.errors == 0) progressStyle += 'progress-bar-success';else progressStyle += 'progress-bar-warning';
		}

		var btnLabel = "Verify OMPL";
		if (this.state.verified) {
			if (this.state.errors == 0) btnLabel = 'OPML Verified';else btnLabel = 'OPML ERROR ';
		}

		var badgeError = this.state.verified && this.state.errors > 0 ? React.createElement(
			Badge,
			null,
			this.state.errors
		) : React.createElement('span', null);
		return React.createElement(
			Jumbotron,
			null,
			React.createElement(
				'h1',
				null,
				'Verify OPML'
			),
			React.createElement(
				'p',
				null,
				'This is a simple hero unit, a simple jumbotron-style component for calling extra attention to featured content or information.'
			),
			React.createElement(
				'div',
				{ className: 'container-fluid' },
				React.createElement(
					'div',
					{ className: 'row' },
					React.createElement(
						'div',
						{ className: 'col-md-4' },
						React.createElement(
							Button,
							{ bsStyle: 'default', className: btnStyle, onClick: this.handleVerifyOPML },
							btnLabel,
							' ',
							badgeError
						)
					),
					React.createElement(
						'div',
						{ className: 'col-md-8' },
						React.createElement(
							'div',
							null,
							React.createElement(UpdateProgressBar, { min: this.state.progress_min, max: this.state.progress_max, barStyle: progressStyle })
						)
					)
				)
			),
			React.createElement(OPMLErrorPane, { messages: this.state.messages })
		);
	}
});

// ProgressBar
var UpdateProgressBar = React.createClass({
	render: function render() {
		var perc = Math.floor(this.props.min / this.props.max * 100);

		return React.createElement(ProgressBar, { id: 'updateProgressBar', className: this.props.barStyle, now: perc, label: '%(percent)s%' });
	}
});

var OPMLErrorPane = React.createClass({
	render: function render() {
		//console.log("RENDER ERROR PANE "  + this.props.messages.length)
		var errorMessages = this.props.messages.map(function (message, i) {
			return React.createElement(
				'tr',
				{ key: i },
				React.createElement(
					'td',
					null,
					i + 1
				),
				React.createElement(
					'td',
					null,
					message.details.category
				),
				' ',
				React.createElement(
					'td',
					null,
					message.details.rule
				),
				' ',
				React.createElement(
					'td',
					null,
					message.details.detail
				),
				' '
			);
		}.bind(this));
		var table_head = this.props.messages.length > 0 ? React.createElement(
			'thead',
			null,
			' ',
			React.createElement(
				'tr',
				null,
				React.createElement(
					'th',
					null,
					'#'
				),
				React.createElement(
					'th',
					null,
					'Category'
				),
				' ',
				React.createElement(
					'th',
					null,
					'Rule'
				),
				' ',
				React.createElement(
					'th',
					null,
					'Description'
				),
				' '
			),
			' '
		) : React.createElement('thead', null); //(<thead> <tr><th></th><th></th> <th></th> <th></th> </tr> </thead>)
		return React.createElement(
			'div',
			{ id: 'verifyOPMLErrorTable' },
			React.createElement(
				Table,
				{ className: 'table' },
				table_head,
				React.createElement(
					'tbody',
					null,
					errorMessages
				)
			)
		);
	}
});

var CardUpdateTaxonomy = React.createClass({
	getInitialState: function getInitialState() {
		return { canNext: false, canPrev: true, currentJob: '', currentNode: '', progress_max: 0, progress_min: 0, updated: false };
	},

	componentWillMount: function componentWillMount() {
		this.props.changePrevNext(this.state.canPrev, this.state.canNext);
		socket.on('taxonomy', this.dispatchMessages);
	},

	componentWillUnmount: function componentWillUnmount() {
		socket.removeListener('taxonomy', this.dispatchMessages);
	},

	handdleUdateTaxonomy: function handdleUdateTaxonomy() {
		if (this.state.currentJob.length > 0) return;

		this.setState({ canNext: false, canPrev: false, updated: false, currentJob: '', currentNode: '', progress_max: 0, progress_min: 0 });
		this.props.changePrevNext(this.state.canPrev, this.state.canNext);

		$.ajax({ method: 'PUT', url: '/taxonomy/', data: {} }).done(function (msg) {
			//
		}.bind(this));
	},

	dispatchMessages: function dispatchMessages(msg) {
		// PROCESS START -> END
		if (msg.description == "taxonomy:update:started") this.setState({ currentJob: "Starting Taxonomy Update", currentNode: '' });
		if (msg.description == "taxonomy:update:ended") {
			this.setState({ currentJob: '', currentNode: '', progress_max: 0, progress_min: 0, updated: true, canNext: true, canPrev: true });
			this.props.changePrevNext(this.state.canPrev, this.state.canNext);
		}

		// READ DATA
		if (msg.description == "taxonomy:read:opml") this.setState({ currentJob: "OPML Readed" });
		if (msg.description == "taxonomy:categories:loaded") this.setState({ currentJob: "DMP Categories Loaded" });
		if (msg.description == "taxonomy:rules:loaded") this.setState({ currentJob: "DMP Rules Loaded" });
		if (msg.description == "taxonomy:update:opml") this.setState({ currentJob: "OPML Updated" });

		// TAXONOMY CATEGORIES
		if (msg.description == "taxonomy:delete:categories:limbo") this.setState({ currentJob: "Deleting LIMBO Categories" });
		if (msg.description == "taxonomy:update:categories:started") this.setState({ currentJob: "Updating Taxonomy Categories", progress_max: 0, progress_min: 0 });
		if (msg.description == "taxonomy:update:category") this.setState({ progress_max: msg.details.total, progress_min: msg.details.current, currentNode: "Updating Category: " + msg.details.category.name + " [ID:" + msg.details.category.id + "]" });

		// TAXONOMY RULES
		if (msg.description == "taxonomy:update:rules:started") this.setState({ currentJob: "Updating Taxonomy Rules", currentNode: '', progress_max: 0, progress_min: 0 });
		if (msg.description == "taxonomy:update:rule") this.setState({ progress_max: msg.details.total, progress_min: msg.details.current, currentNode: "Updating Rule: " + msg.details.rule.name + " [ID:" + msg.details.rule.id + "]" });
	},

	render: function render() {
		var counter = this.state.progress_min > 0 ? React.createElement(
			'span',
			null,
			this.state.progress_min,
			'/',
			this.state.progress_max
		) : React.createElement('span', null);
		var btnText = this.state.updated ? "TAXONOMY UPDATED" : "UPDATE TAXONOMY";
		var btnStyle = this.state.updated ? "btn-raised btn-success" : "btn-raised btn-default";
		var progressStyle = this.state.updated ? 'progress-bar-success' : '';
		var spinning = this.state.currentJob.length > 0 ? React.createElement('span', { className: 'glyphicon glyphicon-refresh spin' }) : React.createElement('span', null);

		return React.createElement(
			Jumbotron,
			null,
			React.createElement(
				'h1',
				null,
				'Update Taxonomy'
			),
			React.createElement(
				'p',
				null,
				'This is a simple hero unit, a simple jumbotron-style component for calling extra attention to featured content or information.'
			),
			React.createElement(
				'div',
				{ className: 'container-fluid' },
				React.createElement(
					'div',
					{ className: 'row' },
					React.createElement(
						'div',
						{ className: 'col-md-4' },
						React.createElement(
							Button,
							{ className: btnStyle, onClick: this.handdleUdateTaxonomy },
							btnText,
							' ',
							spinning
						)
					),
					React.createElement(
						'div',
						{ className: 'col-md-8' },
						React.createElement(
							'h3',
							null,
							this.state.currentJob,
							' ',
							counter
						),
						React.createElement(
							'p',
							null,
							React.createElement(UpdateProgressBar, { min: this.state.progress_min, max: this.state.progress_max, barStyle: progressStyle })
						),
						React.createElement(
							'p',
							{ id: 'taxonomy_job_node' },
							this.state.currentNode
						)
					)
				)
			)
		);
	}
});

var CardDownloadOPML = React.createClass({
	getInitialState: function getInitialState() {
		return { canNext: false, canPrev: true, opmlFileHref: '' };
	},

	componentWillMount: function componentWillMount() {
		this.props.changePrevNext(this.state.canPrev, this.state.canNext);
	},

	componentDidMount: function componentDidMount() {
		//var url = URL.createObjectURL(result);

		$.ajax({ method: 'GET', url: '/taxonomy/opml/', 'xhrFields': { 'responseType': 'blob' }, 'dataType': 'binary', processData: false }).done(function (msg) {
			//var url = URL.createObjectURL(msg)
			//$("a").attr("href", url)
			console.log(msg);
			this.setState({ opmlFileHref: URL.createObjectURL(msg) });
			console.log(url);
		}.bind(this));
	},

	render: function render() {
		var opmlFileName = 'taxonomy' + this.props.current_mode + '.opml';
		return React.createElement(
			Jumbotron,
			null,
			React.createElement(
				'h1',
				null,
				'Download OPML'
			),
			React.createElement(
				'p',
				null,
				'This is a simple hero unit, a simple jumbotron-style component for calling extra attention to featured content or information.'
			),
			React.createElement(
				'div',
				{ className: 'container-fluid' },
				React.createElement(
					'div',
					{ className: 'row' },
					React.createElement('div', { className: 'col-md-4' }),
					React.createElement(
						'div',
						{ className: 'col-md-4' },
						React.createElement(
							'a',
							{ href: this.state.opmlFileHref, id: 'downloadOPMLLink', download: opmlFileName },
							'DownloadOPML'
						),
						'  ',
						React.createElement('span', { id: 'iconDonwloadOPML', className: 'glyphicon glyphicon-cloud-download' })
					),
					React.createElement('div', { className: 'col-md-4' })
				)
			)
		);
	}
});

ReactDOM.render(React.createElement(SequencePanel, { numCards: 5, modes: [{ value: "_dev", label: "Development" }, { value: "_prod", label: "Production" }] }), document.getElementById('reactMountingNode'));