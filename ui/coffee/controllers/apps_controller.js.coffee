class Show
  constructor: (@ctx) ->
    @Envs = app.model 'recipes'
    @app = @ctx.params.id
    @envs = []
    @Envs.get(app: @app).done (data) =>
      console.log data
      @envs = data
      @ctx.app.refresh()


app.addController 'apps#show', Show
