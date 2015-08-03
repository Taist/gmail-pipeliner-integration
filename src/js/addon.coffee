app = require './app'

reactId = require('react/lib/DOMProperty').ID_ATTRIBUTE_NAME

styleWrapLongLinesForSelect = ''

# fixes styles for material-ui
innerHTML = ''
innerHTML += '\n.selectFieldWrapper div[tabindex="0"] div { text-overflow: ellipsis; overflow-x: hidden; }'
innerHTML += '\n.selectFieldWrapper div[' + reactId + '$=".2.0.1:1"] { box-sizing: border-box; overflow: hidden; padding-right: 24px; height: 56px; white-space: nowrap; text-overflow: ellipsis; } '

style = document.createElement 'style'
style.innerHTML = innerHTML
document.getElementsByTagName('head')[0].appendChild style

#
injectTapEventPlugin = require 'react-tap-event-plugin'
injectTapEventPlugin()

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app
    app.init _taistApi

    require('./api/gmail').init app, 'gMailAPI'
    require('./api/pipeliner').init app, 'pipelinerAPI'

    DOMObserver = require './helpers/domObserver'
    app.elementObserver = new DOMObserver()

    app.container = document.createElement 'div'

    app.messageContainer = document.createElement 'div'
    app.renderMessage('')

    app.getPipelinerCreds()

    .then () ->
      app.pipelinerAPI.getClients()

    .then (clients) ->
      app.actions.onLoadClients clients
      .map (client) ->
        client.name = "#{client.FIRSTNAME} #{client.LASTNAME}"
        client

    .finally (result) ->
      app.elementObserver.waitElement 'table[role="presentation"]>tr>td:first-child', (parent) ->
        parent.insertBefore app.container, parent.querySelector 'div'
        parent.insertBefore app.messageContainer, parent.querySelector 'div'

        mailId = location.hash.match(/(?:#[a-z]+\/)([a-z0-9]+)/i)?[1]
        if mailId
          participants = app.gMailAPI.getParticipants parent

        app.actions.onChangeMail participants

    .catch (err) ->
      app.renderMessage err
      console.log err



module.exports = addonEntry
