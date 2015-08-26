React = require 'react'

{ div, h3 } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Table, TextField, RaisedButton, SelectField } = mui

GMailLead = React.createFactory React.createClass
  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: () ->
    muiTheme: ThemeManager.getCurrentTheme()

  getInitialState: () ->
    selectedSalesUnit: null

    leadName: ''
    selectedContactId: null

  updateComponent: (newProps) ->
    newState = @getInitialState()
    newState.selectedSalesUnit = @props.data.selectedSalesUnit

    @setState newState, =>
      if newProps.data.selectedSalesUnit?.SALES_UNIT_NAME?
        @refs.salesUnitSelector.getDOMNode()
        .querySelector("div")
        .querySelector("div div:nth-child(3)")
        .innerText = newProps.data.selectedSalesUnit?.SALES_UNIT_NAME

  componentDidMount: ->
    @updateComponent @props

  componentWillReceiveProps: (newProps) ->
    @updateComponent newProps

  onSelectSalesUnit: (event, index, selectedSalesUnit) ->
    @props.actions.onSelectSalesUnit selectedSalesUnit
    # @setState { selectedSalesUnit }

  onRowSelection: (selectedRows) ->
    @setState selectedContactId: @tableData[selectedRows[0]].id

  onChange: (fieldName, event) ->
    valueObj = {}
    valueObj[fieldName] = event.target.value
    @setState valueObj

  onCreateLead: ->
    if @state.selectedSalesUnit?

      if @state.leadName.replace(/\s/g, '') is ''
        @props.actions.showMessage 'Please fill in lead name'
        return

      @props.actions.onCreateLead @state.leadName, @state.selectedContactId
      .then =>
        @props.reactActions?.backToMain();

    else
      @props.actions.showMessage 'Please select client and sales unit'

  render: ->
    @tableData = @props.data.participants
      .filter (person) =>
        not @props.data.contacts[person.email] is false
      .map (person) =>
        id: @props.data.contacts[person.email].ID
        name: content: person.name

    div {},
      h3 {}, 'Create lead'
      div { className: 'section group' },

        div { className: 'col span_1_of_2' },
          div { className: 'selectFieldWrapper' },
            React.createElement SelectField, {
              ref: 'salesUnitSelector'
              menuItems: @props.data.salesUnits
              valueMember: 'ID'
              displayMember: 'SALES_UNIT_NAME'
              floatingLabelText: 'Sales Unit'
              value: @state.selectedSalesUnit
              onChange: @onSelectSalesUnit
              fullWidth: true
            }

          React.createElement TextField, {
            floatingLabelText: "Lead Name"
            value: @state.leadName
            fullWidth: true
            onChange: (event, value) => @onChange 'leadName', event, value
          }

        div { className: 'col span_1_of_2' },
          div {}, 'Pipeliner contacts'
          div {className: 'changeCheckboxTdWidth'},
            React.createElement Table, {
              columnOrder: ['name']
              showRowHover: true
              deselectOnClickaway: false
              onRowSelection: @onRowSelection
              rowData: @tableData
            }

      div { style: textAlign: 'right' },

        React.createElement RaisedButton, {
          label: 'Create lead'
          onClick: @onCreateLead
          disabled: not @state.selectedContactId
        }

        div { style: width: 8, display: 'inline-block' }

        React.createElement RaisedButton, {
          label: 'Close'
          onClick: @props.reactActions?.backToMain
        }

module.exports = GMailLead
