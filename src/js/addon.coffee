app = require './app'

React = require 'react'

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app
    app.init _taistApi

    require('./api/gmail').init app, 'gMailAPI'
    require('./api/pipeliner').init app, 'pipelinerAPI'

    DOMObserver = require './helpers/domObserver'
    app.elementObserver = new DOMObserver()

    app.pipelinerAPI.getRequest 'Clients'
    .then (a) ->
      console.log a
    .catch (err) ->
      console.log err

    app.elementObserver.waitElement 'table[role="presentation"]>tr>td:first-child', (parent) ->
      container = document.createElement 'div'
      parent.insertBefore container, parent.querySelector 'div'

      mailId = location.hash.match(/(?:#[a-z]+\/)([a-z0-9]+)/i)?[1]
      if mailId
        pageData = {
          text: JSON.stringify app.gMailAPI.getParticipants parent
        }

      GmailBlock = require './react/gmailBlock'
      React.render ( GmailBlock { pageData } ), container

module.exports = addonEntry
