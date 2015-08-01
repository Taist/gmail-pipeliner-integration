Q = require 'q'

require('react/lib/DOMProperty').ID_ATTRIBUTE_NAME = 'data-vr-gm-crm-reactid'

React = require 'react'
extend = require 'react/lib/Object.assign'

appData =
  clients: []
  participants: []

app =
  api: null
  exapi: {}

  init: (api) ->
    app.api = api

    app.exapi.setUserData = Q.nbind api.userData.set, api.userData
    app.exapi.getUserData = Q.nbind api.userData.get, api.userData

    app.exapi.setCompanyData = Q.nbind api.companyData.set, api.companyData
    app.exapi.getCompanyData = Q.nbind api.companyData.get, api.companyData

    app.exapi.setPartOfCompanyData = Q.nbind api.companyData.setPart, api.companyData
    app.exapi.getPartOfCompanyData = Q.nbind api.companyData.getPart, api.companyData

    app.exapi.updateCompanyData = (key, newData) ->
      app.exapi.getCompanyData key
      .then (storedData) ->
        updatedData = {}
        extend updatedData, storedData, newData
        app.exapi.setCompanyData key, updatedData
        .then ->
          updatedData

  container: null
  render: ->
    gMailBlock = require './react/gmailBlock'
    React.render ( gMailBlock data: appData, actions: app.actions ), app.container

  messageContainer: null
  renderMessage: ( message ) ->
    messageSnackbar = require './react/messageSnackbar'
    React.render ( messageSnackbar { message } ), app.messageContainer

  _data: -> appData

  actions:
    onLoadClients: (clients = []) ->
      appData.clients = clients

    onChangeMail: (participants = []) ->
      appData.participants = participants.filter (person) ->
        !appData.clients.filter((client) -> client.EMAIL is person.email).length
      app.render()

    onCreateContact: (selectedContact, selectedClient, data) ->
      app.pipelinerAPI.createContact {
        OWNER_ID: selectedClient.ID # mandatory field
        EMAIL1: selectedContact.email
        FIRST_NAME: data.firstName
        SURNAME: data.lastName
        PHONE1: data.clientPhone
        SALES_UNIT_ID: selectedClient.DEFAULT_SALES_UNIT_ID # mandatory field
      }
      .then (result) ->
        app.renderMessage 'Contact successfully created'
      .catch (error) ->
        app.renderMessage error

module.exports = app
