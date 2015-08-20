React = require 'react'
extend = require 'react/lib/Object.assign'

{ div, h3 } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ TextField, RaisedButton, SelectField } = mui

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

      selectedClient: null
    }

  updateComponent: (newProps) ->
    creds = newProps.data.pipelinerCreds
    @setState creds, =>
      if newProps.data.pipelinerCreds.selectedClient?.name?
        @refs.clientSelector.getDOMNode()
        .querySelector("div")
        .querySelector("div div:nth-child(3)")
        .innerText = newProps.data.pipelinerCreds.selectedClient.name

  componentDidMount: () ->
    @updateComponent @props

  componentWillReceiveProps: (newProps) ->
    @updateComponent newProps

  onChange: (fieldName, event) ->
    valueObj = {}
    valueObj[fieldName] = event.target.value
    @setState valueObj

  onSelectClient: (event, index, selectedClient) ->
    @setState { selectedClient }

  render: ->
    div {},
      h3 {}, 'Settings'
      div { className: 'section group' },

        div { className: 'col span_1_of_2' },
          div { className: 'selectFieldWrapper' },
            React.createElement SelectField, {
              ref: 'clientSelector'
              menuItems: @props.data.clients
              valueMember: 'ID'
              displayMember: 'name'
              floatingLabelText: 'Client'
              defaultValue: @props.data.pipelinerCreds?.selectedClient?.name
              value: @state.selectedClient
              onChange: @onSelectClient
              fullWidth: true
            }

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
            label: 'Save'
            onClick: =>
              @props.actions.onSaveCreds? extend {}, @state
              @props.reactActions?.backToMain()
          }

          div { style: width: 16, display: 'inline-block' }, ''

          React.createElement RaisedButton, {
            label: 'Cancel'
            onClick: @props.reactActions?.backToMain
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
