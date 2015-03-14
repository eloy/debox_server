class SiteController
  @beforeAction: () ->
    unless app.getCookie 'debox_auth'
      return redirect: '/sessions/sign_in'

  constructor: (@ctx) ->
    Apps = app.model 'apps'
    @apps = []
    Apps.index().done (data) =>
      @apps = data
      @ctx.app.refresh()


app.addController 'site_controller', SiteController
