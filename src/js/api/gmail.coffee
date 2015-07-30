app = null

gMailAPI =
  name: 'GMail API'

  getParticipants: (container) ->
    userIndex = []

    [].slice.apply(
      container.querySelectorAll 'h3>span[email],td>span[email]'
    )
    .map (elem) ->
      email = elem.getAttribute 'email'
      name = elem.getAttribute 'name'
      userIndex.push email
      { email, name, text: "#{name} (#{email})" }
    .filter (user, idx) ->
      idx is userIndex.indexOf user.email

module.exports =
  init: (_app, propertyName) ->
    app = _app
    _app[propertyName] = gMailAPI
