require "debox_server/job_execution"

class Job < ActiveRecord::Base

  include DeboxServer::JobExecution

  # associations
  #----------------------------------------------------------------------

  belongs_to :recipe


  def to_jbuilder(opt={  })
    Jbuilder.new do |json|
      json.(self, :id, :task, :recipe_id, :config, :created_at, :start_time, :end_time, :success, :error)
      json.recipe_name self.recipe.name
      json.app_id self.recipe.app_id
      json.app_name self.recipe.app.name
      json.started self.start_time.present?
      json.finished self.end_time.present?

      json.log(self.log) unless opt[:no_log]
    end
  end
end
