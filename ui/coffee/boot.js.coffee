window.app = app = new UnicoApp enableRouter: true, templateBasePath: '/tmpl'
window.app.debug = true

window.onload = ->
  app.liveLogger.start()
  app.startRouter()
