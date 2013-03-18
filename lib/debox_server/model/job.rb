class Job < ActiveRecord::Base

  include DeboxServer::JobExecution
  # associations
  #----------------------------------------------------------------------

  belongs_to :recipe

end
