class LiveLogger
  constructor: ->
    @envs = {}

  state: (app, env) ->
    key = app + "::" + env
    @envs[key] ||= {}

  start: ->
    Status = app.model 'status'
    Status.get().done (jobs) =>
      for job in jobs
        console.log job
        state = @state(job.app_name, job.recipe_name)
        if job.started == true
          state.running = true
          state.job = job
          state.log = ""
      app.refresh()

    es = new EventSource '/v1/live/notifications'
    es.onopen = ->
      console.log "Connected"

    es.onerror =  ->
      console.error "Can't connect to live events"

    es.onmessage = (event) =>
      data = JSON.parse event.data
      console.log data
      job = data.job
      state = @state(job.app_name, job.recipe_name)
      if data.notification == 'stdout' && data.data
        state.log += data.data
      else if data.notification == "finished"
        state.running = false
      else if data.notification == "started"
        state.running = true
        state.job = job
        state.log = ""

      app.refresh()

app.liveLogger = new LiveLogger()
