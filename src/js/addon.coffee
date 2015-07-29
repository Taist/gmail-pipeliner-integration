app = require './app'

React = require 'react'

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app
    app.init _taistApi

    DOMObserver = require './helpers/domObserver'
    app.elementObserver = new DOMObserver()

    app.elementObserver.waitElement '[role="presentation"]>tr>td:first-child', (parent) ->
      console.log 'gMail observer'

      container = document.createElement 'div'
      parent.insertBefore container, parent.querySelector 'div'

      mailId = location.hash.match(/(?:#inbox\/)([a-z0-9]+)/i)?[1]
      if mailId
        pageData = {
          mailId
        }

      GmailBlock = require './react/gmailBlock'
      React.render ( GmailBlock { pageData } ), container

module.exports = addonEntry
