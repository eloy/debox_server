class App < ActiveRecord::Base

  # validations
  #----------------------------------------------------------------------

  validates_presence_of :name
  validates_uniqueness_of :name

end
