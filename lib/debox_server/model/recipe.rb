class Recipe < ActiveRecord::Base

  # associations
  #----------------------------------------------------------------------

  belongs_to :app
  has_many :jobs
  has_many :permissions

  # validations
  #----------------------------------------------------------------------

  validates_presence_of :name, :content
  validates_uniqueness_of :name, scope: :app_id

end
