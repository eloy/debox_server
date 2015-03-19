app.addModel 'status', '/v1/status'
app.addModel 'session', '/v1/session/new'
app.addModel 'apps', '/v1/apps'
app.addModel 'recipes', '/v1/recipes/:app/:env'
app.addModel 'cap', '/v1/cap/:app/:env'
app.addModel 'logs', '/v1/logs/:app/:env'
app.addModel 'log', '/v1/log/:app/:env' # TODO: Remove
app.addModel 'envs', '/v1/apps/:app/envs/:env/:action'
app.addModel 'jobs', '/v1/apps/:app/envs/:env/jobs/:id/:action'
