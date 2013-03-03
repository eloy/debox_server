module DeboxServer
  module Recipes
    include DeboxServer::Utils

    RECIPE_TEMPLATE = 'recipe_new.rb.erb'

    # Create a new recipe
    def create_recipe(app_name, env, content)
      return false if recipe_exists? app, env
      app = App.find_by_name_or_create(app_name)
      redis.hsetnx recipe_app_key(app_name), env, content
      # Add app if no present
      redis_save
    end

    # Update recipe if present
    def update_recipe(app, env, content)
      return false unless recipe_exists? app, env
      redis.hset recipe_app_key(app), env, content
      redis_save
    end

    # Create recipe if not present
    def new_recipe(app, env)
      recipe = ERB.new recipe_template
      recipe.result binding
    end

    def recipes_destroy(app, env)
      redis.hdel recipe_app_key(app), env
      redis_save
    end

    # Return true if one recipe for the given app and env
    # exits
    def recipe_exists?(app, env)
      redis.hexists recipe_app_key(app), env
    end

    # Return the recipe content
    def recipe_content(app, env)
      redis.hget(recipe_app_key(app), env) || false
    end

    def recipes_list(app)
      redis.hkeys recipe_app_key(app)
    end

    def recipe_app_key(app)
      "#{app}_recipes"
    end

    def recipe_template
      @recipe_template ||= recipe_template_content
    end

    def recipe_template_content
      name = File.join DEBOX_ROOT, 'assets', RECIPE_TEMPLATE
      File.open(name).read
    end

  end
end
