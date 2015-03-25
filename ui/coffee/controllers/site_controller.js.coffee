class SiteController extends Debox.BaseController

  constructor: (@ctx) ->
    Apps = app.model 'apps'
    @apps = []
    Apps.index().done (data) =>
      @apps = data
      @ctx.app.refresh()


app.addController 'site_controller', SiteController
