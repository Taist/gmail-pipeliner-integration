app = require './app'

Q = require 'q'

fixMaterialUIStyles = ->
  #fixes internal issues of Material UI
  #TODO: remove when it becomes fixed in Material UI itself
  style = document.createElement 'style'

  reactId = require('react/lib/DOMProperty').ID_ATTRIBUTE_NAME
  style.innerHTML = """
      .selectFieldWrapper div[tabindex="0"] div {
        text-overflow: ellipsis; overflow-x: hidden;
      }

      .selectFieldWrapper div[#{reactId}$=".2.0.1:1"] {
        box-sizing: border-box; overflow: hidden; padding-right: 24px; height: 56px; white-space: nowrap; text-overflow: ellipsis;
      }
  """

  document.getElementsByTagName('head')[0].appendChild style

injectTapEventPlugin = ->
  (require 'react-tap-event-plugin')()

createContainer = ->
  container = document.createElement 'div'
  container.style.position = 'absolute'
  container.style.width = '640px'
  container.style.zIndex = '4'
  container.style.right = '0'
  container.style.display = 'none'

  return container

module.exports =
  start: (_taistApi, entryPoint) ->
    fixMaterialUIStyles()
    injectTapEventPlugin()

    window._app = app
    app.init _taistApi

    app.gMailAPI = require './api/gmail'

    app.pipelinerAPI = new (require('./api/pipeliner'))

    DOMObserver = require './helpers/domObserver'
    app.container = createContainer()

    app.messageContainer = document.createElement 'div'
    app.renderMessage('')

    #VR FOR DEVELOPMENT ONLY
    #app.container.style.display = 'block'

    app.getPipelinerCreds()

    .then () ->
      app.actions.onStart()

    .finally () ->
      elementObserver = new DOMObserver()
      elementObserver.waitElement '.changeCheckboxTdWidth .mui-table-row-column input', (checkbox) ->
        checkbox.parentNode.parentNode.style.width = '24px'

      elementObserver.waitElement 'table[role="presentation"]>tr>td:first-child', (parent) ->
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

