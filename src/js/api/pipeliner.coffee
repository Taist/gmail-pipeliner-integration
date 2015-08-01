Q = require 'q'
app = null

extend = require 'react/lib/Object.assign'

pipelinerAPI = extend require('../helpers/apiRequestInterface'),
  name: 'Pipeliner API'
  # is used for mixin apiRequestInterface
  getApp: -> app

  # is used for mixin apiRequestInterface
  getAPIAddress: (path) ->
    creds = @getCreds()
    "#{creds.serviceURL}/rest_services/v1/#{creds.spaceID}/#{path}"

  # is used for mixin apiRequestInterface
  getAuthorizationHeader: ->
    creds = @getCreds()
    'Basic ' + btoa "#{creds.token}:#{creds.password}"

  getCreds: ->
    token: 'us_Taist_3GKJPC1IGOFDL73R'
    password: 'XQjveyjSsprRF8A2'
    spaceID: 'us_Taist'
    serviceURL: 'https://eu-central-1.pipelinersales.com'

  getClients: ->
    @getRequest 'Clients'

  createContact: (data) ->
    @postRequest 'Contacts', data
    .catch (proxyError) ->
      error = JSON.parse proxyError.response.body
      Q.reject error.message

module.exports =
  init: (_app, propertyName) ->
    app = _app
    _app[propertyName] = pipelinerAPI
