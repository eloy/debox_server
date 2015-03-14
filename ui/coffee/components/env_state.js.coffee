tmpl = '''
{{state()}}
'''

class EnvStateComponent
  @template: tmpl

  build: (ctx, meta) ->
    @env = meta.attrs.env
    @app = meta.attrs.app

  state: ->
    if app.liveLogger.state(@app, @env).running then "running" else ""

app.addComponent 'env-state', EnvStateComponent
