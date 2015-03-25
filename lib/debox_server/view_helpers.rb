module DeboxServer
  module ViewHelpers

    def current_app
      return @request_app if @request_app
      @request_app = App.find_by_name! params[:app]
    end


    def current_env
      return @request_env if @request_env
      app = current_app

      if params[:env]
        @request_env = app.recipes.find_by_name! params[:env]
      else
        if app.recipes.count == 0
          error!("#{current_app} hasn't configured enviments", 400)
        elsif app.recipes.count > 1
          availables = app.recipes.map(&:name).join(', ')
          error!("Enviromnment must be set. Availables: #{availables}.\n", 400)
        else
          @request_env = app.recipes.first
        end
      end

      return @request_env
    end


    def extract_params(key, keys)
      keys = keys.map{|k| k.to_s  }
      params[key].select do |k|
        keys.include? k
      end
    end

  end
end
