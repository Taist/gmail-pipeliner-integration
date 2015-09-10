# wrapper for arbitrary api
# should be initialized with object that provides methods getApp, getAPIAddress and getAuthorizationHeader

Q = require 'q'

extend = require 'react/lib/Object.assign'

module.exports = class ApiRequest
  constructor: ({api, getAPIAddress, getAuthorizationHeader, processResponse, processError}) ->
    @_api = api
    @_getAPIAddress = getAPIAddress
    @_getAuthorizationHeader = getAuthorizationHeader
    @_processResponse = processResponse
    @_processError = processError

  get: (path, data) ->
    if data?
      params =
        (for key, val of data
          "#{key}=#{val}"
        ).join '&'

      path += "?#{params}"

    @_sendRequest path

  post: (path, data) ->
    @_sendRequest path, { data: JSON.stringify(data), method: 'post' }

  put: (path, data) ->
    @_sendRequest path, { data: JSON.stringify(data), method: 'put' }

  _sendRequest: (path, options = {}) ->
    if url = @_getAPIAddress? path
      deferred = Q.defer()

      Authorization = @_getAuthorizationHeader?()

      requestOptions = extend {
        type: 'json'
        method: 'get'
        contentType: 'application/json'
        headers: { Authorization }
      }, options

      @_api.proxy.jQueryAjax url, '', requestOptions, (error, response) =>
        if error
          error = @_processError(error) if @_processError
          deferred.reject error
        else
          response = @_processResponse(response) if @_processResponse
          deferred.resolve response

      deferred.promise
    else
      Q.reject 'Please setup correct API URL'
