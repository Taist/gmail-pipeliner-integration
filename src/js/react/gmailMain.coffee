React = require 'react'

{ h3, div, a } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Table } = mui

GMailMain = React.createFactory React.createClass
  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: () ->
    muiTheme: ThemeManager.getCurrentTheme()

  onClickToCRMButton: (event) ->
    console.log event

  onRowHover: (row) ->
    @setState "rowButtons#{row}": true

  onRowHoverExit: (row) ->
    @setState "rowButtons#{row}": false

  render: () ->
    div {},
      h3 {}, 'Contacts'
      React.createElement Table, {
        columnOrder: ['name', 'email', 'buttons']
        showRowHover: true
        stripeRows: true
        displayRowCheckbox: false
        onRowHover: @onRowHover
        onRowHoverExit: @onRowHoverExit
        rowData: @props.data.participants.map (person, index) =>
          name: content: person.name
          email: content: person.email
          buttons:
            style: width: 48
            content:
              if @props.data.contacts[person.email] is false
                a {
                  href: 'javascript:;'
                  onClick: -> @onClickToCRMButton
                  style:
                    display: if @state?["rowButtons#{index}"] then 'block' else 'none'
                }, 'To CRM'
              else
                ''
      }

module.exports = GMailMain
