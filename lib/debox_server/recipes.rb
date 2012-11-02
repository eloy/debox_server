module DeboxServer
  module Recipes
    include DeboxServer::Utils

    RECIPES_DIR = "recipes.d"
    RECIPE_TEMPLATE = 'recipe_new.rb.erb'

    # Create a new recipe
    def create_recipe(app, env, content)
      return false if recipe_exists? app, env
      prepare_dirs!(app) # TODO: move to save_filee
      file_name = recipe_file_name app, env
      save_file file_name, content
    end

    # Update recipe if present
    def update_recipe(app, env, content)
      return false unless recipe_exists? app, env
      file_name = recipe_file_name app, env
      save_file file_name, content
    end

    # Create recipe if not present
    def new_recipe(app, env)
      recipe = ERB.new recipe_template
      recipe.result binding
    end

    # Return the recipe content
    def recipe_content(app, env)
      return false unless recipe_exists? app, env
      File.open(recipe_file_name app, env).read
    end

    # Return true if one recipe for the given app and env
    # exits
    def recipe_exists?(app, env)
      File.exists? recipe_file_name(app, env)
    end

    def recipe_file_name(app, env)
      File.join recipes_app_dir(app), "#{env}.rb"
    end

    private

    # Create required dirs if no present
    def prepare_dirs!(app)
      Dir.mkdir(recipes_dir) unless Dir.exists? recipes_dir
      Dir.mkdir(recipes_app_dir(app)) unless Dir.exists? recipes_app_dir(app)
    end

    def recipes_dir
      File.join config_dir, RECIPES_DIR
    end

    def recipes_app_dir(app)
      File.join recipes_dir, app
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
