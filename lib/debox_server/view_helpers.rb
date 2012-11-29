module DeboxServer
  module ViewHelpers

    def current_app
      return @request_app if @request_app
      @request_app = params[:app]
      throw(:halt, [400, "App not found.\n"]) unless app_exists? @request_app
      return @request_app
    end


    def current_env
      return @request_env if @request_env
      @request_env = params[:env] || default_env
      throw(:halt, [400, "Environment not found.\n"]) unless recipe_exists? current_app, @request_env
      return @request_env
    end

    # Return the default environment for a given app
    def default_env
      recipes = recipes_list current_app
      throw(:halt, [400, "#{current_app} hasn't configured enviments"]) if recipes.count == 0
      throw(:halt, [400, "Enviromnment must be set. Availables: #{recipes.join(', ')}.\n"]) if recipes.count > 1
      env = recipes.first
    end
  end
end
