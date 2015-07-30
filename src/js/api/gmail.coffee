app = null

gMailAPI =
  name: 'GMail API'

  getParticipants: (container) ->
    [].slice.apply(
      container.querySelectorAll 'h3>span[email],td>span[email]'
    ).map (elem) ->
      email: elem.getAttribute 'email'
      name: elem.getAttribute 'name'

module.exports =
  init: (_app, propertyName) ->
    app = _app
    _app[propertyName] = gMailAPI
