Q = require 'q'

# TODO: критически не хватает коммента - зачем это здесь делается?
# плюс в addon.coffee тоже есть к нему обращение - нужно все обращения запихнуть поближе друг к другу, снабдив соотв. пояснениями
# плохо в одном файле и выполнять какую-то логику, и экспортировать ее - лучше все выполнение запихнуть в init, либо хотя бы вынести в соотв. исполняемый файл - addon.coffee в данном случае

require('react/lib/DOMProperty').ID_ATTRIBUTE_NAME = 'data-vr-gm-crm-reactid'

React = require 'react'
extend = require 'react/lib/Object.assign'

appData =
  pipelinerCreds:
    token: ''
    password: ''
    spaceID: ''
    serviceURL: ''
  clients: []
  salesUnits: []
  contacts: {}
  participants: []

  selectedSalesUnit: null

  attachedLead: null

  isConnectionError: false

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
  render: (options) ->
    gMailBlock = require './react/gmailBlock'
    React.render ( gMailBlock data: appData, actions: app.actions, options: options ), app.container

  messageContainer: null
  renderMessage: ( message ) ->
    messageSnackbar = require './react/messageSnackbar'
    React.render ( messageSnackbar { message } ), app.messageContainer

  getPipelinerCreds: () ->
    app.exapi.getCompanyData 'pipelinerCreds'
    .then (creds) ->
      if creds?
        app.pipelinerAPI.setCreds creds
        appData.pipelinerCreds = creds

      appData.pipelinerCreds

  setPipelinerCreds: (creds) ->
    app.exapi.setCompanyData 'pipelinerCreds', creds
    .then ->
      app.pipelinerAPI.setCreds creds
      appData.pipelinerCreds = creds

  actions:
    showMessage: (message) ->
      app.renderMessage message

    onSaveCreds: (creds) ->
      appData.isConnectionError = false
      app.setPipelinerCreds creds
      .then ->
        app.actions.onStart()

    onConnectionError: () ->
      appData.isConnectionError = true
      app.render activeView: 'settings'

    onStart: () ->
      Q.all [
        app.pipelinerAPI.getClients()
        app.pipelinerAPI.getSalesUnits()
      ]

      .spread (clients, salesUnits) ->
        app.actions.onLoadSalesUnits salesUnits

        app.actions.onLoadClients clients
        .map (client) ->
          client.name = "#{client.FIRSTNAME} #{client.LASTNAME}"
          app.render()
          client

      .catch (error) ->
        app.actions.onConnectionError()

    onLoadClients: (clients = []) ->
      appData.clients = clients

    onLoadSalesUnits: (salesUnits = []) ->
      appData.salesUnits = salesUnits
      if salesUnits.length? > 0
        appData.selectedSalesUnit = salesUnits[0]

    onSelectSalesUnit: (selectedSalesUnit) ->
      appData.selectedSalesUnit = selectedSalesUnit;
      app.render()

    onChangeMail: (participants = []) ->
      appData.participants = participants.filter (person) ->
        !appData.clients.filter((client) -> client.EMAIL is person.email).length
      app.render activeView: 'main'

    onHide: () ->
      app.container.style.display = 'none';

    onUpdateContacts: (contacts) ->
      appData.contacts = contacts
      app.render()

    onLeadInfoUpdated: (leadInfo) ->
      if leadInfo?.ID?
        app.pipelinerAPI.getLead leadInfo.ID
        .then (lead) ->
          appData.attachedLead = lead
          app.render()
        .catch (error) ->
          console.log error
      else
        appData.attachedLead = null
        app.render()

    onChangeAccountName: (accountName) ->
      app.pipelinerAPI.findAccounts accountName
      .then (result) ->
        accounts = result.map (account) =>
          { id: account.ID, value: account.ORGANIZATION }
        accounts.sort (a, b) =>
          if a.value.toLowerCase() < b.value.toLowerCase() then -1 else 1
        accounts
      .catch (error) ->
        console.log error
        []

    onCreateAccount: (accountName) ->
      selectedClient = appData.pipelinerCreds.selectedClient
      unless selectedClient?.ID?
        app.renderMessage 'Please select client on the settings page'
        return

      accountData =
        OWNER_ID: selectedClient.ID # mandatory field
        SALES_UNIT_ID: appData.selectedSalesUnit.ID # mandatory field
        ORGANIZATION: accountName

      app.pipelinerAPI.createAccount(accountData)
      .then (account) ->
        app.renderMessage 'Account successfully created'
        { id: account.ID, value: accountName }

      .catch (error) ->
        console.log error
        app.renderMessage error.toString()


    onCreateContact: (formData) ->
      selectedClient = appData.pipelinerCreds.selectedClient
      unless selectedClient?.ID?
        app.renderMessage 'Please select client on the settings page'
        return

      contactData = {
        OWNER_ID: selectedClient.ID # mandatory field
        SALES_UNIT_ID: appData.selectedSalesUnit.ID # mandatory field
        EMAIL1: formData.clientEmail
        FIRST_NAME: formData.firstName
        SURNAME: formData.lastName
        PHONE1: formData.clientPhone
      }

      if formData.account
        contactData.QUICK_ACCOUNT_NAME = formData.account.value
        contactData.ACCOUNT_RELATIONS = [{
          ACCOUNT_ID: formData.account.id
          IS_PRIMARY: 1
        }]

      app.pipelinerAPI.createContact(contactData)

      .then () ->
        app.renderMessage 'Contact successfully created'
        app.pipelinerAPI.findContacts appData.participants
        .then (contacts) ->
          app.actions.onUpdateContacts contacts

      .catch (error) ->
        console.log error
        app.renderMessage error.toString()

    onCreateLead: (leadName, contactId) ->
      selectedClient = appData.pipelinerCreds.selectedClient
      unless selectedClient?.ID?
        app.renderMessage 'Please select client on the settings page'
        return

      selectedContact = {}
      for _, contact of appData.contacts
        if contact.ID is contactId
          selectedContact = contact
          break

      leadData = {
        OWNER_ID: selectedClient.ID # mandatory field
        SALES_UNIT_ID: appData.selectedSalesUnit.ID # mandatory field
        QUICK_CONTACT_NAME: "#{selectedContact.FIRST_NAME} #{selectedContact.SURNAME}"
        OPPORTUNITY_NAME: leadName
        CONTACT_RELATIONS: [{
          CONTACT_ID: contactId
          IS_PRIMARY: 1
        }]
      }

      app.pipelinerAPI.createLead leadData

      .then (lead) ->
        mailId = location.hash.match(/(?:#[a-z]+\/)([a-z0-9]+)/i)?[1]
        app.exapi.setCompanyData "Lead_#{mailId}", lead
        mailId

      .then (mailId) ->
        app.exapi.getCompanyData "Lead_#{mailId}"
        .then (lead) ->
          app.actions.onLeadInfoUpdated lead
        app.renderMessage 'Lead successfully created'

      .catch (error) ->
        console.log error
        app.renderMessage error.toString()

module.exports = app
