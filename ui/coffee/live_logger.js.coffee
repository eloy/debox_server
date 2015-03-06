class LiveLogger
  start: ->
    es = new EventSource '/v1/live/notifications'
    es.onopen = ->
      console.log "Connected"

    es.onerror = (data) ->
      console.error data

    es.onmessage = (data) ->
      console.dir data


app.liveLogger = new LiveLogger()
