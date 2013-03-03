class Recipe < ActiveRecord::Base

  # associations
  #----------------------------------------------------------------------

  belongs_to :app

  # validations
  #----------------------------------------------------------------------

  validates_presence_of :name, :content
  validates_uniqueness_of :name



end
