# Main UnicoApp
#----------------------------------------------------------------------

window.app = app = new UnicoApp enableRouter: true, templateBasePath: '/tmpl'
window.app.debug = true


window.Debox =

  isLoggedIn: ->
    app.getCookie 'debox_auth'

  startSession: ->
    app.model('session').get().done (data) =>
      @user = data

    @liveLogger.start()




class BaseController
  user: -> Debox.user

window.Debox.BaseController = BaseController


window.onload = ->
  Debox.startSession() if Debox.isLoggedIn()
  app.startRouter()
