import React from 'react';

class TodoList extends React.Component {
  render() {
    var _this = this;
    var createItem = (item, index) => {
      return (
        <li key={ index }>
          { item.text }
          <span onClick={ _this.props.removeItem.bind(null, item['.key']) }
                style=>
            X
          </span>
        </li>
      );
    };

    return <ul>{ this.props.items.map(createItem) }</ul>;
  }
}

class TodoApp extends React.Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
      items: [],
      text: ''
    };
  }

  componentWillMount() {
    this.firebaseRef = firebase.database().ref('todoApp/items');
    this.firebaseRef.limitToLast(25).on('value', function(dataSnapshot) {
      var items = [];
      dataSnapshot.forEach(childSnapshot => {
        const item = childSnapshot.val();
        item['.key'] = childSnapshot.key;
        items.push(item);
      });

      this.setState({
        items: items
      });
    }.bind(this));
  }

  componentWillUnmount() {
    this.firebaseRef.off();
  }

  onChange(e) {
    this.setState({text: e.target.value});
  }

  removeItem(key) {
    var firebaseRef = firebase.database().ref('todoApp/items');;
    firebaseRef.child(key).remove();
  }

  handleSubmit(e) {
    e.preventDefault();
    if (this.state.text && this.state.text.trim().length !== 0) {
      this.firebaseRef.push({
        text: this.state.text
      });
      this.setState({
        text: ''
      });
    }
  }

  render() {
    return (
      <div>
        <TodoList items={ this.state.items } removeItem={ this.removeItem } />
        <form onSubmit={ this.handleSubmit }>
          <input onChange={ this.onChange } value={ this.state.text } />
          <button>{ 'Add #' + (this.state.items.length + 1) }</button>
        </form>
      </div>
    );
  }
}

ReactDOM.render(<TodoApp />, document.getElementById('todoApp'));
