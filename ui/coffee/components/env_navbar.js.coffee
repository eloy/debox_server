tmpl = '''
  <ul class="nav nav-tabs">
    <li role="presentation" xclass="active"><a href="/apps/{{app}}/envs/{{env}}">Overview</a></li>
    <li role="presentation"><a href="/apps/{{app}}/envs/{{env}}/logs">Logs</a></li>
    <li role="presentation"><a href="/apps/{{app}}/envs/{{env}}/recipe">Recipes</a></li>
    <li role="presentation"><a href="/apps/{{app}}/envs/{{env}}/tasks">Tasks</a></li>
  </ul>
'''

class EnvNavbarComponent
  @template: tmpl


app.addComponent 'env-navbar', EnvNavbarComponent
