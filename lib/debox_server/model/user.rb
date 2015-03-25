class User < ActiveRecord::Base
  include DeboxServer::Utils
  # validations
  #----------------------------------------------------------------------

  validates_presence_of :email, :password
  validates_uniqueness_of :email

  # associations
  #----------------------------------------------------------------------

  has_many :permissions

  # callback
  #----------------------------------------------------------------------

  before_create :create_api_key

  def password=(clean_password)
    crypted_password = hash_str(clean_password)
    write_attribute :password, crypted_password
  end

  def make_admin!
    self.update_attribute :admin, true
  end

  def remove_admin!
    self.update_attribute :admin, false
  end

  # permissions
  #----------------------------------------------------------------------

  def permissions_for_recipe(recipe)
    self.permissions.where(recipe_id: recipe.id)
  end

  # Return true if the current user has permissions
  # for the givent action on the given recipe
  # Example
  # user.can? :cap, on: recipe
  def can?(action, options)
    recipe = options[:on] || fail(":on parameter is mandatory")
    action = action.to_s
    return true if self.admin?
    permissions_for_recipe(recipe).each do |p|
      return true if p.action == '*' || p.action == action
    end
    return false
  end


  # JSON
  #----------------------------------------------------------------------

  def to_jbuilder(opt={  })
    Jbuilder.new do |json|
      json.(self, :id, :email, :admin)
      if opt[:verbose]
        json.acl self.permissions.includes(:recipe) do |perm|
          json.app_id perm.recipe.app_id
          json.app perm.recipe.app.name
          json.env_id perm.recipe_id
          json.env perm.recipe.name
          json.action perm.action
        end
      end
    end
  end

  private

  def create_api_key
    return if api_key.present?
    self.api_key = SecureRandom.uuid
  end
end
