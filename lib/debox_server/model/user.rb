class User < ActiveRecord::Base

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

  private

  def create_api_key
    return if api_key.present?
    self.api_key = SecureRandom.uuid
  end
end
