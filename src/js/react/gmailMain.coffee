React = require 'react'

{ h3, div, a, svg, path } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Table, RaisedButton, Paper } = mui

GMailMain = React.createFactory React.createClass
  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: () ->
    muiTheme: ThemeManager.getCurrentTheme()

  onClickToCRMButton: (person) ->
    @props.reactActions.onClickToCRMButton person

  onRowHover: (row) ->
    @setState "rowButtons#{row}": true

  onRowHoverExit: (row) ->
    @setState "rowButtons#{row}": false

  render: () ->
    div {},
      h3 {}, 'Contacts'

      if @props.data.participants?.length < 1
        React.createElement Paper, {
          zDepth: 3
          rounded: false
          style:
            padding: 16
        },
          div {}, 'Contacts not found on the current page'

      React.createElement Table, {
        columnOrder: ['name', 'email', 'buttons']
        showRowHover: true
        stripeRows: true
        displayRowCheckbox: false
        onRowHover: @onRowHover
        onRowHoverExit: @onRowHoverExit
        rowData: @props.data.participants.map (person, index) =>
          name:
            content: person.name
          email:
            content: person.email
          buttons:
            style: width: 24
            content:
              if @props.data.contacts[person.email] is false
                a {
                  href: 'javascript:;'
                  onClick: => @onClickToCRMButton person
                  title: 'Add to CRM'
                  # style:
                  #   display: if @state?["rowButtons#{index}"] then 'block' else 'none'
                },
                  svg { viewBox: '0 0 24 24' },
                    path d: "M15 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm-9-2V7H4v3H1v2h3v3h2v-3h3v-2H6zm9 4c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"
              else
                svg { viewBox: '0 0 24 24' },
                  path d: "M12 5.9c1.16 0 2.1.94 2.1 2.1s-.94 2.1-2.1 2.1S9.9 9.16 9.9 8s.94-2.1 2.1-2.1m0 9c2.97 0 6.1 1.46 6.1 2.1v1.1H5.9V17c0-.64 3.13-2.1 6.1-2.1M12 4C9.79 4 8 5.79 8 8s1.79 4 4 4 4-1.79 4-4-1.79-4-4-4zm0 9c-2.67 0-8 1.34-8 4v3h16v-3c0-2.66-5.33-4-8-4z"
      }

      h3 {}, 'Lead'
        if @props.data.attachedLead?.ID?
          div {}, @props.data.attachedLead.OPPORTUNITY_NAME, ' (', @props.data.attachedLead.QUICK_CONTACT_NAME, ')'
        else
          React.createElement RaisedButton, {
            label: 'Create lead'
            onClick: @props.reactActions.onClickCreateLeadButton
          }

module.exports = GMailMain
