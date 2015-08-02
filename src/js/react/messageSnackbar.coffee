React = require 'react'

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Snackbar } = mui

MessageSnackbar = React.createFactory React.createClass
  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: () ->
    muiTheme: ThemeManager.getCurrentTheme()

  componentWillReceiveProps: (newProps) ->
    if newProps.message?.length > 0
      @refs.snackbar.show()

  render: ->
    React.createElement Snackbar, {
      ref: 'snackbar'
      message: @props?.message
      autoHideDuration: 5000
      onActionTouchTap: => @refs.snackbar.dismiss()
    }

module.exports = MessageSnackbar
