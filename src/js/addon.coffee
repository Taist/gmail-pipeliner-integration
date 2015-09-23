app = require './app'

Q = require 'q'

xmlHttpProxy = require './helpers/xmlHttpProxy'

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

_pipelinerButton = null
getPipelinerButton = (donorButton) ->

  unless _pipelinerButton
    button = document.createElement 'div'
    button.style.display = 'inline-block'
    button.innerText = 'Pipeliner'
    # button.style.position = 'absolute'
    button.className = donorButton.className
    button.onclick = ->
      app.container.style.display = 'block'
    _pipelinerButton = button

  return _pipelinerButton

onChangeThead = (mailId) ->
    container = document.querySelector('[gh="mtb"]').parentNode;
    container.appendChild app.container
    container.appendChild app.messageContainer

    if mailId
      selector = 'table[role="presentation"]>tr>td:first-child'
      parent = document.querySelector selector

      participants = app.gMailAPI.getParticipants parent

      app.pipelinerAPI.findContacts participants
      .then (contacts) ->
        app.actions.onUpdateContacts contacts
      .catch (error) ->
        console.log 'app.pipelinerAPI.findContacts onError', error

      app.exapi.getCompanyData "Lead_#{mailId}"
      .then (lead) ->
        app.actions.onLeadInfoUpdated lead

    app.actions.onChangeMail participants

module.exports =
  start: (_taistApi, entryPoint) ->
    fixMaterialUIStyles()
    injectTapEventPlugin()

    window._app = app
    app.init _taistApi

    app.gMailAPI = require './api/gmail'

    PipelinerAPI = require './api/pipeliner'
    app.pipelinerAPI = new PipelinerAPI app

    DOMObserver = require './helpers/domObserver'
    app.container = createContainer()

    app.messageContainer = document.createElement 'div'
    app.renderMessage('')

    #VR FOR DEVELOPMENT ONLY
    #app.container.style.display = 'block'

    responseHandler = (request) ->
      url = request.responseURL;
      matches = url.match /&view=ad.*&th=([a-f0-9]+)/i
      if(threadId = matches?[1])
        console.log matches, url, threadId
        onChangeThead threadId


    targetWindow = document.getElementById("js_frame").contentDocument.defaultView;
    xmlHttpProxy.onRequestFinish {window: targetWindow, responseHandler}

    app.getPipelinerCreds()

    .then (creds) ->
      app.actions.onStart()

    .finally () ->
      elementObserver = new DOMObserver()

      # fix for column width of material-ui tables
      elementObserver.waitElement '.changeCheckboxTdWidth .mui-table-row-column input', (checkbox) ->
        checkbox.parentNode.parentNode.style.width = '24px'

      elementObserver.waitElement '[gh="mtb"]>div [role="button"]:first-child', (donorButton) ->
        donorButton.parentNode.appendChild getPipelinerButton donorButton

      elementObserver.waitElement 'table[role="presentation"]>tr>td:first-child', (parent) ->
        #do nothing

    .catch (err) ->
      app.renderMessage err
      console.log err
