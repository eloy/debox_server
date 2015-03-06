router = app.router

router.rootOptions partial: '/home/index.html', controller: 'site_controller'
router.route '/sessions/sign_in', partial: '/sessions/index.html', controller: 'sessions_controller#sign_in'

# apps
router.resources 'apps', {}, (member, collection) ->
  member.resources 'envs'

router.resources 'users'
