module DeboxServer
  module Recipes
    include DeboxServer::Utils

    RECIPE_TEMPLATE = 'recipe_new.rb.erb'

    # Create a new recipe
    def create_recipe(app_name, name, content)
      app = App.find_by_name_or_create(app_name)
      recipe = Recipe.create app: app, name: name, content: content
      return false unless recipe.valid?
      return recipe
    end

    # Update recipe if present
    def update_recipe(app_name, name, content)
      app = App.find_by_name! app_name
      recipe = app.recipes.find_by_name! name
      recipe.update_attributes content: content
    end

    # Create recipe if not present
    def new_recipe(app, env)
      recipe = ERB.new recipe_template
      recipe.result binding
    end

    def recipes_destroy(app_name, name)
      app = App.find_by_name! app_name
      recipe = app.recipes.find_by_name! name
      recipe.destroy
    end

    # Return the recipe content
    def recipe_content(app_name, name)
      app = App.find_by_name! app_name
      recipe = app.recipes.find_by_name! name
      recipe.content
    end

    def recipe_app_key(app)
      "#{app}_recipes"
    end

    def recipe_template
      @recipe_template ||= recipe_template_content
    end

    def recipe_template_content
      name = File.join Config.debox_root, 'assets', RECIPE_TEMPLATE
      File.open(name).read
    end

  end
end
