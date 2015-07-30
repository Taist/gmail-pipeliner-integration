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

module.exports =
  init: (_app, propertyName) ->
    app = _app
    _app[propertyName] = pipelinerAPI
