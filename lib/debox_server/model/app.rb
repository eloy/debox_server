class App < ActiveRecord::Base

  # associations
  #----------------------------------------------------------------------

  has_many :recipes

  # validations
  #----------------------------------------------------------------------

  validates_presence_of :name
  validates_uniqueness_of :name

  def recipe_names
    self.recipes.map(&:name)
  end

  def self.find_by_name_or_create(name)
    app = App.find_by_name name
    unless app
      app = App.create name: name
    end
    return app
  end
end
