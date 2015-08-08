React = require 'react'

{ div, span } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Snackbar, TextField, SelectField, RaisedButton } = mui

GmailContactForm = React.createFactory React.createClass
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
      clientEmail: ''
      clientPhone: ''
      clientCompany: ''

      snackbarMessage: ''
    }

  updateComponent: (newProps) ->
    newState = @getInitialState()
    newState.selectedClient = @state.selectedClient

    @setState { newState, selectedContact: newProps.activePerson },  =>
      if newProps.activePerson
        matches = newProps.activePerson.name.match /(\S+)\s?(.*)/
        @setState { firstName: matches[1], lastName: matches[2], clientEmail: newProps.activePerson.email }

  componentDidMount: ->
    @updateComponent @props

  componentWillReceiveProps: (newProps) ->
    @updateComponent newProps

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
        clientEmail: @state.clientEmail
        clientPhone: @state.clientPhone
        clientCompany: @state.clientCompany
        leadName: @state.leadName
      }
    else
      @showMessage 'Please select contact person and client'

  render: ->
    div {},

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
              menuItems: @props.data.clients
              valueMember: 'ID'
              displayMember: 'name'
              floatingLabelText: 'Selected Client'
              value: @state.selectedClient
              onChange: @onSelectClient
              fullWidth: true
            }

        div { className: 'col span_1_of_2' },
          React.createElement TextField, {
            floatingLabelText: "Company"
            value: @state.clientCompany
            fullWidth: true
            onChange: (event, value) => @onChange 'clientCompany', event, value
          }

      div { className: 'section group' },

        div { className: 'col span_1_of_2' },
          React.createElement TextField, {
            floatingLabelText: "First Name"
            value: @state.firstName
            fullWidth: true
            onChange: (event, value) => @onChange 'firstName', event, value
          }

          React.createElement TextField, {
            floatingLabelText: "Email"
            value: @state.clientEmail
            fullWidth: true
            disabled: true
            onChange: (event, value) => @onChange 'clientEmail', event, value
          }

        div { className: 'col span_1_of_2' },

          React.createElement TextField, {
            floatingLabelText: "Last Name"
            value: @state.lastName
            fullWidth: true
            onChange: (event, value) => @onChange 'lastName', event, value
          }

          React.createElement TextField, {
            floatingLabelText: "Phone"
            value: @state.clientPhone
            fullWidth: true
            onChange: (event, value) => @onChange 'clientPhone', event, value
          }

      div { style: textAlign: 'right' },

        React.createElement RaisedButton, {
          label: 'Add to CRM'
          onClick: @onCreateContact
        }

        div { style: width: 8, display: 'inline-block' }

        React.createElement RaisedButton, {
          label: 'Cancel'
          onClick: @props.reactActions?.backToMain
        }

module.exports = GmailContactForm
