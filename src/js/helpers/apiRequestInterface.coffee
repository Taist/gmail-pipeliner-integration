# mixin for API queries
# extended object should implement methods getApp, getAPIAddress and getAuthorizationHeader

Q = require 'q'

extend = require 'react/lib/Object.assign'

module.exports =
  getRequest: (path) ->
    @sendRequest path

  postRequest: (path, data) ->
    @sendRequest path, { data: JSON.stringify(data), method: 'post' }

  putRequest: (path, data) ->
    @sendRequest path, { data: JSON.stringify(data), method: 'put' }

  sendRequest: (path, options = {}) ->
    deferred = Q.defer()

    url = @getAPIAddress? path

    Authorization = @getAuthorizationHeader?()

    console.log url, Authorization

    requestOptions = extend {
      type: 'json'
      method: 'get'
      contentType: 'application/json'
      headers: { Authorization }
    }, options

    @getApp?().api.proxy.jQueryAjax url, '', requestOptions, (error, response) ->
      if error
        deferred.reject error
      else
        deferred.resolve response.result

    deferred.promise
