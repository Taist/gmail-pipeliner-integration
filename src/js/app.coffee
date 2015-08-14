Q = require 'q'

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
  contacts: []
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
      app.setPipelinerCreds creds

    onLoadClients: (clients = []) ->
      appData.clients = clients

    onLoadSalesUnits: (salesUnits = []) ->
      appData.salesUnits = salesUnits

    onChangeMail: (participants = []) ->
      appData.participants = participants.filter (person) ->
        !appData.clients.filter((client) -> client.EMAIL is person.email).length
      app.render activeView: 'main'

    onHide: () ->
      app.container.style.display = 'none';

    onUpdateContacts: (contacts) ->
      appData.contacts = contacts
      app.render()

    onChangeAccountName: (accountName) ->
      app.pipelinerAPI.findAccounts accountName
      .then (result) ->
        console.log 'onChangeAccountName', accountName, result
        accounts = result.map (account) =>
          { id: account.ID, value: account.ORGANIZATION }
        accounts.sort (a, b) =>
          if a.value.toLowerCase() < b.value.toLowerCase() then -1 else 1
        accounts
      .catch (error) ->
        console.log error
        []

    onCreateAccount: (selectedClient, selectedSalesUnit, accountName) ->
      accountData =
        OWNER_ID: selectedClient.ID # mandatory field
        SALES_UNIT_ID: selectedSalesUnit.ID # mandatory field
        ORGANIZATION: accountName

      app.pipelinerAPI.createAccount(accountData)
      .then (account) ->
        app.renderMessage 'Account successfully created'
        account.value = accountName
        account

      .catch (error) ->
        console.log error
        app.renderMessage error.toString()



    onCreateContact: (selectedClient, selectedSalesUnit, formData) ->
      Q.all(
          []
      )

      .spread () ->
        contactData = {
          OWNER_ID: selectedClient.ID # mandatory field
          SALES_UNIT_ID: selectedSalesUnit.ID # mandatory field
          EMAIL1: formData.clientEmail
          FIRST_NAME: formData.firstName
          SURNAME: formData.lastName
          PHONE1: formData.clientPhone
        }
        Q.all [ app.pipelinerAPI.createContact(contactData), contactData ]

      # .spread (contact, account, contactData) ->
      #   console.log 'starts to create lead'
      #   if formData.leadName?.length > 0
      #     leadData = {
      #       OWNER_ID: selectedClient.ID # mandatory field
      #       SALES_UNIT_ID: selectedClient.DEFAULT_SALES_UNIT_ID # mandatory field
      #       OPPORTUNITY_NAME: formData.leadName
      #       CONTACT_RELATIONS: [{
      #         CONTACT_ID: contact.ID
      #         IS_PRIMARY: 1
      #       }]
      #     }
      #     app.pipelinerAPI.postRequest 'Leads', leadData

      # .spread (contact, account, contactData) ->
      #   Q.all [
      #     contact,
      #     account,
      #     contactData,
      #     app.pipelinerAPI.postRequest 'AddressbookRelations', {
      #       ACCOUNT_ID: account.ID
      #       CONTACT_ID: contact.ID
      #       PARENT_CONTACT_ID: 'ROOT'
      #       IS_PRIMARY: 1
      #     }
      #   ]

      # .spread (contact, account, contactData) ->
      #   if account.ID?
      #     contactData.ACCOUNT_RELATIONS = [{
      #       ACCOUNT_ID: account.ID
      #       IS_PRIMARY: 1
      #     }]
      #   app.pipelinerAPI.putRequest "Contacts/#{contact.ID}", contactData

      .then () ->
        app.renderMessage 'Contact successfully created'

      .catch (error) ->
        console.log error
        app.renderMessage error.toString()

module.exports = app
