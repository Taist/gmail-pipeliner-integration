React = require 'react'
extend = require 'react/lib/Object.assign'

{ div, path } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Paper, FlatButton, SvgIcon } = mui

GMailMain = require './gmailMain'
GMailContactForm = require './gmailContactForm'
GMailCredsForm = require './gmailCredsForm'
GMailLead = require './gmailLead'

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
    if newProps.options?.activeView? or newProps.data.isConnectionError
      @setState activeView: if newProps.data.isConnectionError then 'settings' else newProps.options.activeView

  backToMain: ->
    @setState activeView: 'main'

  onClickToCRMButton: (person) ->
    @setState activePerson: person, activeView: 'addContact'

  onClickSettingsIcon: ->
    @setState activeView: 'settings'

  onClickCreateLeadButton: ->
    @setState activeView: 'createLead'

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
          viewBox: '0 0 24 24'
          onClick: @onClickSettingsIcon
          style:
            cursor: 'pointer'
        }, path d: 'M19.43 12.98c.04-.32.07-.64.07-.98s-.03-.66-.07-.98l2.11-1.65c.19-.15.24-.42.12-.64l-2-3.46c-.12-.22-.39-.3-.61-.22l-2.49 1c-.52-.4-1.08-.73-1.69-.98l-.38-2.65C14.46 2.18 14.25 2 14 2h-4c-.25 0-.46.18-.49.42l-.38 2.65c-.61.25-1.17.59-1.69.98l-2.49-1c-.23-.09-.49 0-.61.22l-2 3.46c-.13.22-.07.49.12.64l2.11 1.65c-.04.32-.07.65-.07.98s.03.66.07.98l-2.11 1.65c-.19.15-.24.42-.12.64l2 3.46c.12.22.39.3.61.22l2.49-1c.52.4 1.08.73 1.69.98l.38 2.65c.03.24.24.42.49.42h4c.25 0 .46-.18.49-.42l.38-2.65c.61-.25 1.17-.59 1.69-.98l2.49 1c.23.09.49 0 .61-.22l2-3.46c.12-.22.07-.49-.12-.64l-2.11-1.65zM12 15.5c-1.93 0-3.5-1.57-3.5-3.5s1.57-3.5 3.5-3.5 3.5 1.57 3.5 3.5-1.57 3.5-3.5 3.5z'

        div { style: display: 'inline-block', width: 8 }

        React.createElement SvgIcon, {
          viewBox: '0 0 24 24'
          onClick: @props.actions.onHide
          style:
            cursor: 'pointer'
        }, path d: 'M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z'

      switch @state.activeView
        when 'main'
          GMailMain extend {}, @props,
            reactActions:
              onClickToCRMButton: @onClickToCRMButton
              onClickCreateLeadButton: @onClickCreateLeadButton
        when 'addContact'
          GMailContactForm extend {}, @props, activePerson: @state.activePerson, reactActions: backToMain: @backToMain
        when 'settings'
          GMailCredsForm extend {}, @props, reactActions: backToMain: @backToMain
        when 'createLead'
          GMailLead extend {}, @props, reactActions: backToMain: @backToMain

module.exports = GmailBlock
