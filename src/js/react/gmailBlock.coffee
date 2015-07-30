React = require 'react'

{ div, button } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Paper, RaisedButton, SelectField } = mui

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
    selectedContact: @props.data.participants[0]?.email
    selectedClient: null

  onSelectContact: (selectedContact) ->
    @setState { selectedContact }

  onSelectClient: (selectedClient) ->
    @setState { selectedClient }

  onClick: ->
    console.log 'onClick'

  render: ->
    console.log @props.data

    React.createElement Paper, {
      zDepth: 1
      rounded: false
      style:
        margin: 4
        marginRight: 40
        padding: 8
        boxSizing: 'border-box'
    },

      div { className: 'section group' },

        div { className: 'col span_1_of_2' },
          div {},
            React.createElement SelectField, {
              menuItems: @props.data.participants
              valueMember: 'email'
              displayMember: 'text'
              floatingLabelText: 'Selected Contact Person'
              value: @state.selectedContact
              onChange: @onSelectContact
              fullWidth: true
            }

        div { className: 'col span_1_of_2' },
          div {},
            React.createElement SelectField, {
              menuItems: @props.data.clients
              valueMember: 'ID'
              displayMember: 'name'
              floatingLabelText: 'Selected Client'
              value: @state.selectedClient
              onChange: @onSelectClient
              fullWidth: true
            }

          div {},
            React.createElement RaisedButton, {
              label: 'Button'
              onClick: @onClick
            }

module.exports = GmailBlock
