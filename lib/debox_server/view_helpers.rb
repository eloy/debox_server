module DeboxServer
  module ViewHelpers

    def current_app
      return @request_app if @request_app
      @request_app = params[:app]
      error!("App not found", 400) unless app_exists? @request_app
      return @request_app
    end


    def current_env
      return @request_env if @request_env
      @request_env = params[:env] || default_env
      error!("Environment not found.", 400) unless recipe_exists? current_app, @request_env
      return @request_env
    end

    # Return the default environment for a given app
    def default_env
      recipes = recipes_list current_app
      error!("#{current_app} hasn't configured enviments", 400) if recipes.count == 0
      error!("Enviromnment must be set. Availables: #{recipes.join(', ')}.\n", 400) if recipes.count > 1
      env = recipes.first
    end
  end
end
