React = require 'react'

{ div } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ TextField, RaisedButton } = mui

GmailCredsForm = React.createFactory React.createClass
  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: () ->
    muiTheme: ThemeManager.getCurrentTheme()

  getInitialState: ->
    state = {
      token: ''
      password: ''
      spaceID: ''
      serviceURL: ''
    }

  onChange: (fieldName, event) ->
    valueObj = {}
    valueObj[fieldName] = event.target.value
    @setState valueObj

  render: ->
    div { className: 'section group' },

      div { className: 'col span_1_of_2' },
        React.createElement TextField, {
          floatingLabelText: 'API Token'
          value: @state.token
          fullWidth: true
          onChange: (event, value) => @onChange 'token', event, value
        }

        React.createElement TextField, {
          floatingLabelText: "API Password"
          value: @state.password
          fullWidth: true
          onChange: (event, value) => @onChange 'password', event, value
        }

        React.createElement RaisedButton, {
          label: 'Save API Data'
          onClick: @onCreateContact
        }

        div { style: width: 16, display: 'inline-block' }, ''

        React.createElement RaisedButton, {
          label: 'Change API keys'
          onClick: @props.reactActions?.toggleMode
        }
        
      div { className: 'col span_1_of_2' },
        React.createElement TextField, {
          floatingLabelText: "Space ID"
          value: @state.spaceID
          fullWidth: true
          onChange: (event, value) => @onChange 'spaceID', event, value
        }

        React.createElement TextField, {
          floatingLabelText: "Service URL"
          value: @state.serviceURL
          fullWidth: true
          onChange: (event, value) => @onChange 'serviceURL', event, value
        }

module.exports = GmailCredsForm
