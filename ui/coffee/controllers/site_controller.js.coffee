class SiteController
  @beforeAction: () ->
    unless app.getCookie 'debox_auth'
      return redirect: '/sessions/sign_in'

  constructor: (@ctx) ->

    Status = app.model 'status'
    Apps = app.model 'apps'
    @status = {}
    Status.get().done (data) =>
      @status = data

    @apps = []
    Apps.index().done (data) =>
      console.log data
      @apps = data
      @ctx.app.refresh()


app.addController 'site_controller', SiteController
