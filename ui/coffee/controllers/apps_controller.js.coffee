class Show
  constructor: (@ctx) ->
    @Apps = app.model 'apps'
    @app = @ctx.params.id
    @appData = {}
    @Apps.get(id: @app).done (data) =>
      console.log data
      @appData = data
      @ctx.app.refresh()


app.addController 'apps#show', Show
