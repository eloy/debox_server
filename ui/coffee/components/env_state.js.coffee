tmpl = '''
<span class="label label-success" if="state(app, env).running">{{state(app, env).job.task}}</span>
'''

class EnvStateComponent
  @template: tmpl

  build: (ctx, meta) ->
    @env = meta.attrs.env
    @app = meta.attrs.app

  state: (appName, envName)->
    app.liveLogger.state(appName, envName)

app.addComponent 'env-state', EnvStateComponent
