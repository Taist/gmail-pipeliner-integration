app = require './app'

Q = require 'q'

reactId = require('react/lib/DOMProperty').ID_ATTRIBUTE_NAME

fixMaterialUIStyles = ->
  #fixes internal issues of Material UI
  #TODO: remove when it becomes fixed in Material UI itself
  innerHTML = ''
  innerHTML += '\n.selectFieldWrapper div[tabindex="0"] div { text-overflow: ellipsis; overflow-x: hidden; }'
  innerHTML += '\n.selectFieldWrapper div[' + reactId + '$=".2.0.1:1"] { box-sizing: border-box; overflow: hidden; padding-right: 24px; height: 56px; white-space: nowrap; text-overflow: ellipsis; } '

  style = document.createElement 'style'
  style.innerHTML = innerHTML
  document.getElementsByTagName('head')[0].appendChild style

injectTapEventPlugin = ->
  (require 'react-tap-event-plugin')()

module.exports =
  start: (_taistApi, entryPoint) ->
    fixMaterialUIStyles()
    injectTapEventPlugin()

    window._app = app
    app.init _taistApi

    require('./api/gmail').init app, 'gMailAPI'
    require('./api/pipeliner').init app, 'pipelinerAPI'

    DOMObserver = require './helpers/domObserver'
    app.elementObserver = new DOMObserver()

    app.container = document.createElement 'div'
    app.container.style.position = 'absolute'
    app.container.style.width = '640px'
    app.container.style.zIndex = '4'
    app.container.style.right = '0'
    app.container.style.display = 'none'

    app.messageContainer = document.createElement 'div'
    app.renderMessage('')

    #VR FOR DEVELOPMENT ONLY
    #app.container.style.display = 'block'

    app.getPipelinerCreds()

    .then () ->
      app.actions.onStart()

    .finally () ->

      app.elementObserver.waitElement '.changeCheckboxTdWidth .mui-table-row-column input', (checkbox) ->
        checkbox.parentNode.parentNode.style.width = '24px'

      app.elementObserver.waitElement 'table[role="presentation"]>tr>td:first-child', (parent) ->
        parent.insertBefore app.container, parent.querySelector 'div'
        parent.insertBefore app.messageContainer, parent.querySelector 'div'

        buttonsContainer = document.querySelector '[gh="mtb"]>div'
        donorButton = buttonsContainer.querySelector '[role="button"]'

        button = document.createElement 'div'
        button.style.display = 'inline-block'
        button.innerText = 'Pipeliner'
        button.className = donorButton.className
        button.onclick = ->
          app.container.style.display = 'block'

        buttonsContainer.appendChild button

        # buttonsContainer.appendChild app.container
        # buttonsContainer.appendChild app.messageContainer

        mailId = location.hash.match(/(?:#[a-z]+\/)([a-z0-9]+)/i)?[1]
        if mailId
          participants = app.gMailAPI.getParticipants parent

          app.pipelinerAPI.findContacts participants
          .then (contacts) ->
            app.actions.onUpdateContacts contacts

          app.exapi.getCompanyData "Lead_#{mailId}"
          .then (lead) ->
            app.actions.onLeadInfoUpdated lead

        app.actions.onChangeMail participants

    .catch (err) ->
      app.renderMessage err
      console.log err

