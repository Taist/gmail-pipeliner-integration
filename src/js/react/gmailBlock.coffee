React = require 'react'
extend = require 'react/lib/Object.assign'

{ div, path } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Paper, FlatButton, SvgIcon } = mui

GMailContactForm = require './gmailContactForm'
GMailCredsForm = require './gmailCredsForm'

GMailMain = require './gmailMain'

GmailBlock = React.createFactory React.createClass
  getInitialState: ->
    activeView: 'main'
    activePerson: null

  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: () ->
    muiTheme: ThemeManager.getCurrentTheme()

  componentWillReceiveProps: (newProps) ->
    console.log newProps
    if newProps.options?.activeView?
      @setState activeView: newProps.options.activeView

  backToMain: ->
    @setState activeView: 'main'

  onClickToCRMButton: (person) ->
    @setState activePerson: person, activeView: 'addContact'

  onClickSettingsIcon: ->
    @setState activeView: 'settings'

  render: ->
    React.createElement Paper, {
      zDepth: 2
      rounded: false
      style:
        position: 'relative'
        margin: 4
        marginRight: 16
        padding: "8px 16px 8px 16px"
        boxSizing: 'border-box'
    },
      div {
          style:
            position: 'absolute'
            top: 12
            right: 8
        },

        React.createElement SvgIcon, {
          viewBox: '0 0 1792 1792'
          onClick: @onClickSettingsIcon
          style:
            cursor: 'pointer'
        }, path d: 'M1152 896q0-106-75-181t-181-75-181 75-75 181 75 181 181 75 181-75 75-181zm512-109v222q0 12-8 23t-20 13l-185 28q-19 54-39 91 35 50 107 138 10 12 10 25t-9 23q-27 37-99 108t-94 71q-12 0-26-9l-138-108q-44 23-91 38-16 136-29 186-7 28-36 28h-222q-14 0-24.5-8.5t-11.5-21.5l-28-184q-49-16-90-37l-141 107q-10 9-25 9-14 0-25-11-126-114-165-168-7-10-7-23 0-12 8-23 15-21 51-66.5t54-70.5q-27-50-41-99l-183-27q-13-2-21-12.5t-8-23.5v-222q0-12 8-23t19-13l186-28q14-46 39-92-40-57-107-138-10-12-10-24 0-10 9-23 26-36 98.5-107.5t94.5-71.5q13 0 26 10l138 107q44-23 91-38 16-136 29-186 7-28 36-28h222q14 0 24.5 8.5t11.5 21.5l28 184q49 16 90 37l142-107q9-9 24-9 13 0 25 10 129 119 165 170 7 8 7 22 0 12-8 23-15 21-51 66.5t-54 70.5q26 50 41 98l183 28q13 2 21 12.5t8 23.5z'

        div { style: display: 'inline-block', width: 8 }

        React.createElement SvgIcon, {
          viewBox: '0 0 1792 1792'
          onClick: @props.actions.onHide
          style:
            cursor: 'pointer'
        }, path d: 'M1490 1322q0 40-28 68l-136 136q-28 28-68 28t-68-28l-294-294-294 294q-28 28-68 28t-68-28l-136-136q-28-28-28-68t28-68l294-294-294-294q-28-28-28-68t28-68l136-136q28-28 68-28t68 28l294 294 294-294q28-28 68-28t68 28l136 136q28 28 28 68t-28 68l-294 294 294 294q28 28 28 68z'

      switch @state.activeView
        when 'main'
          GMailMain extend {}, @props, reactActions: onClickToCRMButton: @onClickToCRMButton
        when 'addContact'
          GMailContactForm extend {}, @props, activePerson: @state.activePerson, reactActions: backToMain: @backToMain
        when 'settings'
          GMailCredsForm extend {}, @props, reactActions: backToMain: @backToMain

module.exports = GmailBlock
