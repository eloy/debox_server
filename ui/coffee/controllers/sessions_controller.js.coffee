class SignInController
  constructor: (@ctx) ->
    @auth = {}
    @Session = app.model('session')

  login: ->
    user = @auth.user
    @Session.get({}, @auth).done (data) ->
      app.visit '/'
    @auth = {}

app.addController 'sessions_controller#sign_in', SignInController
