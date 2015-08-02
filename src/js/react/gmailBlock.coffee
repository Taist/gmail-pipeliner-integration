React = require 'react'

{ div } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Paper } = mui

GMailContactForm = require './gmailContactForm'

GmailBlock = React.createFactory React.createClass
  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: () ->
    muiTheme: ThemeManager.getCurrentTheme()

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
      GMailContactForm @props

module.exports = GmailBlock
