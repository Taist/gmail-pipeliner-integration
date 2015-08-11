React = require 'react'

{ div, span, h3 } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ TextField, SelectField, RaisedButton } = mui

CustomSelect = require './taist/customSelect'

GmailContactForm = React.createFactory React.createClass
  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: () ->
    muiTheme: ThemeManager.getCurrentTheme()

  getInitialState: ->
    state = {
      selectedClient: null
      selectedSalesUnit: null

      selectedContact: null
      firstName: ''
      lastName: ''
      clientEmail: ''
      clientPhone: ''
      clientCompany: ''

      selectedAccount: null
    }

  updateComponent: (newProps) ->
    newState = @getInitialState()
    newState.selectedClient = @state.selectedClient
    newState.selectedSalesUnit = @state.selectedSalesUnit

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

  onSelectSalesUnit: (event, index, selectedSalesUnit) ->
    @setState { selectedSalesUnit }

  onChange: (fieldName, event) ->
    valueObj = {}
    valueObj[fieldName] = event.target.value
    @setState valueObj

  onSelectAccount: (selectedAccount) ->
    @setState { selectedAccount }

  onCreateContact: ->
    if @state.selectedClient? and @state.selectedSalesUnit?
        @props.actions.onCreateContact @state.selectedClient, @state.selectedSalesUnit, {
          firstName: @state.firstName
          lastName: @state.lastName
          clientEmail: @state.clientEmail
          clientPhone: @state.clientPhone
          clientCompany: @state.clientCompany
        }
    else
      @props.actions.showMessage 'Please select client and sales unit'

  render: ->
    div {},
      h3 {}, 'Add contact to Pipeliner'
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

          div { className: 'selectFieldWrapper' },
            React.createElement SelectField, {
              menuItems: @props.data.salesUnits
              valueMember: 'ID'
              displayMember: 'SALES_UNIT_NAME'
              floatingLabelText: 'Selected Sales Unit'
              value: @state.selectedSalesUnit
              onChange: @onSelectSalesUnit
              fullWidth: true
            }

        div { className: 'col span_1_of_2' },
          CustomSelect {
            selectType: 'search'
            onSelect: @onSelectAccount
            onChange: @props.actions.onChangeAccountName
            placeholder: 'Start typing to find an account'
          }

          # React.createElement TextField, {
          #   floatingLabelText: "Company"
          #   value: @state.clientCompany
          #   fullWidth: true
          #   onChange: (event, value) => @onChange 'clientCompany', event, value
          # }

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
