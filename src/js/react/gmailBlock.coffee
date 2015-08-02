React = require 'react'
extend = require 'react/lib/Object.assign'

{ div } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Paper } = mui

GMailContactForm = require './gmailContactForm'
GMailCredsForm = require './gmailCredsForm'

GmailBlock = React.createFactory React.createClass
  getInitialState: ->
    isMainView: true

  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: () ->
    muiTheme: ThemeManager.getCurrentTheme()

  toggleMode: ->
    @setState isMainView: !@state.isMainView

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
      if @state.isMainView
        GMailContactForm extend {}, @props, reactActions: toggleMode: @toggleMode
      else
        GMailCredsForm extend {}, @props, reactActions: toggleMode: @toggleMode

module.exports = GmailBlock
