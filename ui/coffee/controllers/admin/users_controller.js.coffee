class Index extends Debox.AdminController

  constructor: (@ctx) ->
    @model = app.model 'users'
    @users = []
    @model.index().done (data) =>
      @users = data
      @ctx.app.refresh()



class Show extends Debox.AdminController
  constructor: (@ctx) ->
    @model = app.model 'users'
    @user = {}
    @model.get(id: @ctx.params.id).done (data) =>
      @user = data
      @ctx.app.refresh()

class Edit extends Debox.AdminController
  constructor: (@ctx) ->
    @model = app.model 'users'
    @user = {}
    @model.get(id: @ctx.params.id).done (data) =>
      @user = data
      @ctx.app.refresh()

  submit: ->
    @model.put({id: @ctx.params.id},{ user: @user}).done (data) =>
      app.visit "/admin/users/#{@ctx.params.id}"

app.addController 'admin_users#index', Index
app.addController 'admin_users#show', Show
app.addController 'admin_users#edit', Edit
