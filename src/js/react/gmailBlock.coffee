React = require 'react'

{ div, button } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Paper, RaisedButton, SelectField, TextField, Snackbar } = mui

injectTapEventPlugin = require 'react-tap-event-plugin'
injectTapEventPlugin()

GmailBlock = React.createFactory React.createClass
  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: () ->
    muiTheme: ThemeManager.getCurrentTheme()

  getInitialState: ->
    state = {
      selectedContact: null
      selectedClient: null
      firstName: ''
      lastName: ''
      clientPhone: ''
      clientCompany: ''
      leadName: ''

      snackbarMessage: ''
  }

  componentWillReceiveProps: () ->
    newState = @getInitialState()
    newState.selectedClient = @state.selectedClient
    @setState newState, =>
      if @props.data.participants[0]?.email?
        @onSelectContact null, null, @props.data.participants[0]

  onSelectContact: (event, index, selectedContact) ->
    @setState { selectedContact }, =>
      if selectedContact
        matches = selectedContact.name.match /(\S+)\s?(.*)/
        @setState { firstName: matches[1], lastName: matches[2] }

  onSelectClient: (event, index, selectedClient) ->
    @setState { selectedClient }

  onChange: (fieldName, event) ->
    valueObj = {}
    valueObj[fieldName] = event.target.value
    @setState valueObj

  showMessage: (snackbarMessage) ->
    @setState { snackbarMessage }, =>
      @refs.snackbar?.show()

  onCreateContact: ->
    if @state.selectedContact? and @state.selectedClient?
      @props.actions.onCreateContact @state.selectedContact, @state.selectedClient, {
        firstName: @state.firstName
        lastName: @state.lastName
        clientPhone: @state.clientPhone
        clientCompany: @state.clientCompany
        leadName: @state.leadName
      }
    else
      @showMessage 'Please select contact person and client'

  render: ->
    React.createElement Paper, {
      zDepth: 1
      rounded: false
      style:
        margin: 4
        marginRight: 40
        padding: 8
        boxSizing: 'border-box'
    },
      div {},
        React.createElement Snackbar, {
          ref: 'snackbar'
          message: @state.snackbarMessage
          autoHideDuration: 5000
          onActionTouchTap: => @refs.snackbar?.dismiss()
        }

      div { className: 'section group' },

        div { className: 'col span_1_of_2' },
          div { className: 'selectFieldWrapper' },
            React.createElement SelectField, {
              menuItems: @props.data.participants
              valueMember: 'email'
              displayMember: 'text'
              floatingLabelText: 'Selected Contact Person'
              value: @state.selectedContact
              onChange: @onSelectContact
              fullWidth: true
            }

            React.createElement TextField, {
              floatingLabelText: "First Name"
              value: @state.firstName
              fullWidth: true
              onChange: (event, value) => @onChange 'firstName', event, value
            }

            React.createElement TextField, {
              floatingLabelText: "Last Name"
              value: @state.lastName
              fullWidth: true
              onChange: (event, value) => @onChange 'lastName', event, value
            }

            # React.createElement TextField, {
            #   floatingLabelText: "Company"
            #   value: @state.clientCompany
            #   fullWidth: true
            #   onChange: (event, value) => @onChange 'clientCompany', event, value
            # }

            React.createElement TextField, {
              floatingLabelText: "Phone"
              value: @state.clientPhone
              fullWidth: true
              onChange: (event, value) => @onChange 'clientPhone', event, value
            }

        div { className: 'col span_1_of_2' },
          div { className: 'selectFieldWrapper' },
            React.createElement SelectField, {
              menuItems: @props.data.clients
              valueMember: 'ID'
              displayMember: 'name'
              floatingLabelText: 'Selected Client'
              value: @state.selectedClient
              onChange: @onSelectClient
              fullWidth: true
            }

            # React.createElement TextField, {
            #   floatingLabelText: "Lead Name"
            #   value: @state.leadName
            #   fullWidth: true
            #   onChange: (event, value) => @onChange 'leadName', event, value
            # }

          div {},
            React.createElement RaisedButton, {
              label: 'Create Contact'
              onClick: @onCreateContact
            }

module.exports = GmailBlock
