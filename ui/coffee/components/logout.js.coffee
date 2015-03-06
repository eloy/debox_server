class LogoutComponent
  @template: '<a href click="logout()">Logout</a>'

  logout: ->
    app.deleteCookie 'debox_auth'
    app.visit '/sessions/sign_in'

app.addComponent 'logout', LogoutComponent
