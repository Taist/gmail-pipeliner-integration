Q = require 'q'
app = null

extend = require 'react/lib/Object.assign'

_creds = {}

_contactsCache = {}

pipelinerAPI = extend require('../helpers/apiRequestInterface'),
  name: 'Pipeliner API'
  # is used for mixin apiRequestInterface
  getApp: -> app

  # is used for mixin apiRequestInterface
  getAPIAddress: (path) ->
    creds = @getCreds()
    # replace with url matching
    if creds.serviceURL?.length > 0
      "#{creds.serviceURL}/rest_services/v1/#{creds.spaceID}/#{path}"

  # is used for mixin apiRequestInterface
  getAuthorizationHeader: ->
    creds = @getCreds()
    'Basic ' + btoa "#{creds.token}:#{creds.password}"

  setCreds: (creds) ->
    _creds = creds

  getCreds: ->
    _creds

  processResponse: (proxyResponse) ->
    if proxyResponse.statusCode is 201
      for header in proxyResponse.headers
        if matches = header.match /^Location:.+\/([^/\s]+)\s+?$/
          return { ID: matches[1] }

    JSON.parse proxyResponse.body

  processError: (proxyError) ->
    JSON.parse(proxyError.response.body).message

  getClients: ->
    @getRequest 'Clients'

  getSalesUnits: ->
    @getRequest 'SalesUnits'

  createContact: (data) ->
    @postRequest 'Contacts', data

  createAccount: (data) ->
    @postRequest 'Accounts', data

  getCachedContact: (email) ->
    _contactsCache[email]

  findContacts: (participants) ->
    Q.all(
      participants.map (p) =>
        filter = "EMAIL1::#{p.email}"
        @getRequest 'Contacts', { filter }
        .then (result) ->
          _contactsCache[p.email] = result[0] or false
    ).then ->
      extend {}, _contactsCache

  findAccounts: (name) ->
    filter = "ORGANIZATION::#{name}::ll"
    @getRequest 'Accounts', { filter }

module.exports =
  init: (_app, propertyName) ->
    app = _app
    _app[propertyName] = pipelinerAPI
