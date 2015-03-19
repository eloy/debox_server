class Show
  constructor: (@ctx) ->
    window.pollo = @
    @Cap = app.model 'cap'
    @Env = app.model 'envs'
    @Job = app.model 'jobs'
    @app = @ctx.params.app_id
    @env = @ctx.params.id
    @userTask = undefined
    @state = app.liveLogger.state(@app, @env)

    # Overview
    #----------------------------------------------------------------------

    @overview = {}
    @Env.get(app: @app, env: @env).done (data) =>
      console.log data
      @overview = data
      @ctx.app.refresh()

    # Tasks
    #----------------------------------------------------------------------

    @tasks = []
    @Env.get(app: @app, env: @env, action: 'tasks').done (data) =>
      @tasks = data
      # Add default value
      @tasks.unshift {name: '',description:''}
      @ctx.app.refresh()


  runTask: ->
    return unless @userTask
    @Cap.get({app: @app, env: @env}, {task: @userTask})

  stop: (id) ->
    @Job.post(app: @app, env: @env, id: id, action: 'stop').done (d) ->
      console.log d

class Tasks
  constructor: (@ctx) ->
    @Cap = app.model 'cap'
    @Env = app.model 'envs'
    @Job = app.model 'jobs'
    @app = @ctx.params.app_id
    @env = @ctx.params.env_id

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
      console.log data[0]
      @logs = data
      @ctx.app.refresh()

class Log
  constructor: (@ctx) ->
    @Log = app.model 'log'
    @app = @ctx.params.app_id
    @env = @ctx.params.env_id
    @log_id = @ctx.params.id
    @log = {}

    @Log.get({app: @app, env: @env}, job_id: @log_id).done (data) =>
      @log = data
      @ctx.app.refresh()


app.addController 'envs#show', Show
app.addController 'envs#logs', Logs
app.addController 'envs#log', Log
app.addController 'envs#tasks', Tasks
app.addController 'envs#recipe', Recipe
