class Show
  constructor: (@ctx) ->
    @Cap = app.model 'cap'
    @app = @ctx.params.app_id
    @env = @ctx.params.id

  cap: (task) ->
    @Cap.get(app: @app, env: @env, task: task).done (data) ->
      console.log data


class Recipe
  constructor: (@ctx) ->
    @Envs = app.model 'recipes'
    @app = @ctx.params.app_id
    @env = @ctx.params.env_id
    @recipe = undefined
    @editMode = false

    @Envs.get(app: @app, env: @env).done (data) =>
      @recipe = data
      @ctx.app.refresh()

  edit: ->
    @editMode = true

  close: ->
    @editMode = false

  save: ->
    @Envs.put({app: @app, env: @env}, {content: @recipe}).done (data) =>
      @close()
      @ctx.app.refresh()

class Logs
  constructor: (@ctx) ->
    @Logs = app.model 'logs'
    @app = @ctx.params.app_id
    @env = @ctx.params.env_id
    @logs = []

    @Logs.get(app: @app, env: @env).done (data) =>
      @logs = data
      @ctx.app.refresh()


app.addController 'envs#show', Show
app.addController 'envs#logs', Logs
app.addController 'envs#recipe', Recipe
