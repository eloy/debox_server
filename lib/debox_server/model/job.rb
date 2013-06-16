require "debox_server/job_execution"

class Job < ActiveRecord::Base

  include DeboxServer::JobExecution
  # associations
  #----------------------------------------------------------------------

  belongs_to :recipe

end
