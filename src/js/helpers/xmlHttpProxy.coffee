_responseHandlers = []
_listening = false
_window = window

_listenToRequests = ->
  originalSend = _window.XMLHttpRequest.prototype.send
  _window.XMLHttpRequest.prototype.send = ->
    _listenForRequestFinish @
    originalSend.apply @, arguments

_listenForRequestFinish = (request) ->
  originalOnReadyStateChange = request.onreadystatechange
  request.onreadystatechange = ->
    finished = request.readyState is 4
    if finished
      for handler in _responseHandlers
        handler request

    originalOnReadyStateChange?.apply request, arguments

module.exports =
  onRequestFinish: (options) ->
    _window = options.window || window
    _responseHandlers.push options.responseHandler
    if not _listening
      _listenToRequests()
