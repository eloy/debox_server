class Permission < ActiveRecord::Base

  VALID_PERMISSIONS = [:*, :cap, :logs, :recipes_admin, :permissions]

  # associations
  #----------------------------------------------------------------------

  belongs_to :recipe
  belongs_to :user

end
