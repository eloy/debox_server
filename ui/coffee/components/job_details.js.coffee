class BitbucketParser
  @match: (config) ->
    return false unless config.repository
    !!config.repository.match(/bitbucket.org/)

  @extract: (config) ->
    matchs = config.repository.match(/git@bitbucket.org:([\w]+)\/([\w]+).git/)
    user = matchs[1]
    repo = matchs[2]
    repo_url = "https://bitbucket.org/#{user}/#{repo}/commits/#{config.real_revision}"
    {repo_url: repo_url}


tmpl = '''
<div if="config && config.branch">
  branch: {{config.branch}}<br/>
  commit: <a target="_blank" href="{{data.repo_url}}">{{config.real_revision}}</a>
</div>
'''

class JobDetailsComponent
  @parsers = [BitbucketParser]
  @template: tmpl

  build: (ctx, meta) ->
    @config = ctx.eval meta.attrs.config
    return unless @config
    parser = @findParser(@config)
    return unless parser
    @data = parser.extract(@config)

  findParser: (config) ->
    return p for p in JobDetailsComponent.parsers when p.match(config)

app.addComponent 'job-details', JobDetailsComponent
