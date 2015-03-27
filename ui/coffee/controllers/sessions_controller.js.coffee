class SignInController extends Debox.BaseController
  @beforeAction: ->

  constructor: (@ctx) ->
    @auth = {}
    @Session = app.model('session')

  login: ->
    user = @auth.user
    @Session.post({}, @auth).done (data) ->
      Debox.startSession()
      app.visit '/'
    @auth = {}

app.addController 'sessions_controller#sign_in', SignInController
