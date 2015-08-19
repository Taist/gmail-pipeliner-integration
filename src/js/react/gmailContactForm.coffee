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

      accountName: ''
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

  onChangeAccountName: (accountName) ->
    @setState { selectedAccount: null, accountName }
    @props.actions.onChangeAccountName accountName

  onCreateContact: ->
    if @state.selectedClient? and @state.selectedSalesUnit?
        @props.actions.onCreateContact @state.selectedClient, @state.selectedSalesUnit, {
          firstName: @state.firstName
          lastName: @state.lastName
          clientEmail: @state.clientEmail
          clientPhone: @state.clientPhone
          clientCompany: @state.clientCompany
          account: @state.selectedAccount
        }
    else
      @props.actions.showMessage 'Please select client and sales unit'

  onCreateAccount: ->
    if @state.selectedClient? and @state.selectedSalesUnit?
      @props.actions.onCreateAccount? @state.selectedClient, @state.selectedSalesUnit, @state.accountName
      .then (createdAccount) =>
        @onSelectAccount createdAccount
        @refs.accountSelector.updateOptions [createdAccount]

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
              floatingLabelText: 'Client'
              value: @state.selectedClient
              onChange: @onSelectClient
              fullWidth: true
            }

          div { className: 'selectFieldWrapper' },
            React.createElement SelectField, {
              menuItems: @props.data.salesUnits
              valueMember: 'ID'
              displayMember: 'SALES_UNIT_NAME'
              floatingLabelText: 'Sales Unit'
              value: @state.selectedSalesUnit
              onChange: @onSelectSalesUnit
              fullWidth: true
            }

        div { className: 'col span_1_of_2' },
          CustomSelect {
            ref: 'accountSelector'
            selectType: 'search'
            onSelect: @onSelectAccount
            onChange: @onChangeAccountName
            placeholder: 'Start typing to find an account'
          }

          div { style: textAlign: 'right'},
            React.createElement RaisedButton, {
              label: 'Create new account'
              onClick: @onCreateAccount
              disabled: @state.selectedAccount? or @state.accountName.length < 1
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
          label: 'Close'
          onClick: @props.reactActions?.backToMain
        }

module.exports = GmailContactForm
