Q = require 'q'

_creds = {}

_contactsCache = {}

apiRequestClass = require('../helpers/apiRequestInterface')

class PipelinerAPI
  constructor: ->
    @_apiRequest = new apiRequestClass {
      api: app.api
      getAPIAddress: (path) =>
        creds = @getCreds()
        # replace with url matching
        if creds.serviceURL?.length > 0
          "#{creds.serviceURL}/rest_services/v1/#{creds.spaceID}/#{path}"
      getAuthorizationHeader: =>
        creds = @getCreds()
        'Basic ' + btoa "#{creds.token}:#{creds.password}"
    }

  name: 'Pipeliner API'

  setCreds: (creds) ->
    _creds = creds

  getCreds: -> _creds

  _get: (path, data) ->
    @_apiRequest.getRequest path, data

  _post: (path, data) ->
    @_apiRequest.postRequest path, data

  processResponse: (proxyResponse) ->
    if proxyResponse.statusCode is 201
      for header in proxyResponse.headers
        if matches = header.match /^Location:.+\/([^/\s]+)\s+?$/
          return { ID: matches[1] }

    JSON.parse proxyResponse.body

  processError: (proxyError) ->
    JSON.parse(proxyError.response.body).message

  getClients: ->
    @_get 'Clients'

  getSalesUnits: ->
    @_get 'SalesUnits'

  createContact: (data) ->
    @_post 'Contacts', data

  createAccount: (data) ->
    @_post 'Accounts', data

  getCachedContact: (email) ->
    _contactsCache[email]

  findContacts: (participants) ->
    Q.all(
      participants.map (p) =>
        filter = "EMAIL1::#{p.email}"
        @_get 'Contacts', { filter }
        .then (result) ->
          _contactsCache[p.email] = result[0] or false
    ).then ->
      extend {}, _contactsCache

  findAccounts: (name) ->
    filter = "ORGANIZATION::#{name}::ll"
    @_get 'Accounts', { filter }

  getLead: (leadId) ->
    @_get "Leads/#{leadId}"

module.exports =
  init: (_app, propertyName) ->
    pipelinerApi = new PipelinerAPI()

    _app[propertyName] = pipelinerApi
