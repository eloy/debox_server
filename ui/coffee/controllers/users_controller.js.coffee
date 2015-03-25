class Index
  constructor: (@ctx) ->
    @model = app.model 'users'
    @users = []
    @model.index().done (data) =>
      console.log data
      @users = data
      @ctx.app.refresh()



class Show
  constructor: (@ctx) ->
    @model = app.model 'users'
    @user = {}
    @model.get(id: @ctx.params.id).done (data) =>
      @user = data
      @ctx.app.refresh()

class Edit
  constructor: (@ctx) ->
    @model = app.model 'users'
    @user = {}
    @model.get(id: @ctx.params.id).done (data) =>
      @user = data
      @ctx.app.refresh()

  submit: ->
    @model.put({id: @ctx.params.id},{ user: @user}).done (data) =>
      console.log data

app.addController 'users#index', Index
app.addController 'users#show', Show
app.addController 'users#edit', Edit
