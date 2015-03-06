class Show
  constructor: (@ctx) ->
    @Envs = app.model 'recipes'
    @Cap = app.model 'cap'
    @app = @ctx.params.app_id
    @env = @ctx.params.id
    @recipe = undefined

    @Envs.get(app: @app, env: @env).done (data) =>
      @recipe = data
      @ctx.app.refresh()


  cap: (task) ->
    @Cap.get(app: @app, env: @env, task: task).done (data) ->
      console.log data

app.addController 'envs#show', Show
