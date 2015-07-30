app = require './app'

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app
    app.init _taistApi

    require('./api/gmail').init app, 'gMailAPI'
    require('./api/pipeliner').init app, 'pipelinerAPI'

    DOMObserver = require './helpers/domObserver'
    app.elementObserver = new DOMObserver()

    app.container = document.createElement 'div'

    app.pipelinerAPI.getRequest 'Clients'
    .then (clients) ->
      app.actions.onLoadClients clients
      .map (client) ->
        client.name = "#{client.FIRSTNAME} #{client.LASTNAME}"
        client
    .catch (err) ->
      console.log err

    app.elementObserver.waitElement 'table[role="presentation"]>tr>td:first-child', (parent) ->
      parent.insertBefore app.container, parent.querySelector 'div'

      mailId = location.hash.match(/(?:#[a-z]+\/)([a-z0-9]+)/i)?[1]
      if mailId
        participants = app.gMailAPI.getParticipants parent

      app.actions.onChangeMail participants


module.exports = addonEntry
