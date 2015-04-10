module DeboxServer
  module API
    module V1

      class Recipes < Grape::API

        version 'v1'

        before do
          authenticate!
          require_admin
        end

        desc "Show env status"
        get "/apps/:app/envs/:env" do
          content_type 'application/json'
          current_env.to_jbuilder.attributes!
        end

        resource :recipes do

          desc "List all the recipes configured for the app"
          get "/:app" do
            app = App.find_by_name! params[:app]
            content_type 'application/json'
            app.recipe_names
          end

          desc "Show a recipe"
          get "/:app/:env" do
            recipe = recipe_content params[:app], params[:env]
            error!("Invalid recipe", 400) unless recipe
            content_type 'text/plain'
            recipe
          end

          desc "Show a default recipe for an application on a given environment"
          get "/:app/:env/new" do
            content_type 'text/plain'
            new_recipe params[:app], params[:env]
          end

          desc "Create a recipe"
          post "/:app/:env" do
            recipe = create_recipe params[:app], params[:env], params[:content]
            error!("Can't create recipe", 400) unless recipe
            content_type 'text/plain'
            "ok"
          end

          desc "Update a recipe"
          put "/:app/:env" do
            update_recipe params[:app], params[:env], params[:content]
            content_type 'text/plain'
            "ok"
          end

          desc "Delete a recipe"
          delete "/:app/:env" do
            recipes_destroy params[:app], params[:env]
            content_type 'text/plain'
            "ok"
          end
        end

      end
    end
  end
end
