require 'rubygems'
require 'bundler'
require 'sprockets'

ENV['DEBOX_ROOT'] ||= File.dirname __FILE__

Bundler.require
require "debox_server/api"

# run DeboxServer::DeboxAPI

class App

  def initialize(options)
    @static = ::Rack::Static.new(lambda { [404, {}, []] }, options)
    @sprokets = Sprockets::Environment.new
    @sprokets.append_path File.join(ENV['DEBOX_ROOT'], 'ui', 'coffee')
    @sprokets.append_path File.join(ENV['DEBOX_ROOT'], 'ui', 'sass')
    @sprokets.append_path File.join(ENV['DEBOX_ROOT'], 'ui', 'vendor', 'js')
    @sprokets.append_path File.join(ENV['DEBOX_ROOT'], 'ui', 'vendor', 'css')

  end

  def call(env)
    orig_path = env['PATH_INFO']

    # there's probably a better way to do this
    if orig_path.starts_with?('/v1/')
      return DeboxServer::DeboxAPI.call(env)
    end

    if orig_path.starts_with?('/assets')
      env['PATH_INFO'] = env['PATH_INFO'][7..-1] # 7 => sizeof /assets
      return @sprokets.call(env)
    end


    if orig_path == "/"
      env['PATH_INFO'] = "/index.html"
    end

    resp = @static.call(env)
  end

end

run App.new(root: File.join(ENV['DEBOX_ROOT'], 'ui', 'public'),  urls: %w[/])
