# mixin for API queries
# extended object should implement methods getApp, getAPIAddress and getAuthorizationHeader

Q = require 'q'

extend = require 'react/lib/Object.assign'

module.exports =
  getRequest: (path, data) ->
    params = if data
      (for key, val of data
        "#{key}=#{val}"
      ).join '&'

    if params
      path += "?#{params}"

    @sendRequest path

  postRequest: (path, data) ->
    @sendRequest path, { data: JSON.stringify(data), method: 'post' }

  putRequest: (path, data) ->
    @sendRequest path, { data: JSON.stringify(data), method: 'put' }

  sendRequest: (path, options = {}) ->
    if url = @getAPIAddress? path
      deferred = Q.defer()

      Authorization = @getAuthorizationHeader?()

      requestOptions = extend {
        type: 'json'
        method: 'get'
        contentType: 'application/json'
        headers: { Authorization }
      }, options

      @getApp?().api.proxy.jQueryAjax url, '', requestOptions, (error, response) =>
        if error
          error = @processError(error) if @processError
          deferred.reject error
        else
          response = @processResponse(response) if @processResponse
          deferred.resolve response

      deferred.promise
    else
      Q.reject 'Please setup correct API URL'
