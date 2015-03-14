class Show
  constructor: (@ctx) ->
    @Cap = app.model 'cap'
    @Env = app.model 'envs'
    @app = @ctx.params.app_id
    @env = @ctx.params.id

    @state = app.liveLogger.state(@app, @env)

    # Overview
    #----------------------------------------------------------------------

    @overview = {}
    @Env.get(app: @app, env: @env).done (data) =>
      @overview = data
      @ctx.app.refresh()

    # Tasks
    #----------------------------------------------------------------------

    @tasks = []
    @Env.get(app: @app, env: @env, action: 'tasks').done (data) =>
      @tasks = data
      @ctx.app.refresh()



  cap: (task) ->
    @Cap.get({app: @app, env: @env}, {task: task}).done (data) ->
      console.log data


class Recipe
  constructor: (@ctx) ->
    @Recipes = app.model 'recipes'
    @app = @ctx.params.app_id
    @env = @ctx.params.env_id
    @recipe = undefined
    @editMode = false

    @Recipes.get(app: @app, env: @env).done (data) =>
      @recipe = data
      @ctx.app.refresh()

  edit: ->
    @editMode = true

  close: ->
    @editMode = false

  save: ->
    @Recipes.put({app: @app, env: @env}, {content: @recipe}).done (data) =>
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
