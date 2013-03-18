class Recipe < ActiveRecord::Base

  # associations
  #----------------------------------------------------------------------

  belongs_to :app
  has_many :jobs

  # validations
  #----------------------------------------------------------------------

  validates_presence_of :name, :content
  validates_uniqueness_of :name

end
