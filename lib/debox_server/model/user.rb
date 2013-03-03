class User < ActiveRecord::Base

  # validations
  #----------------------------------------------------------------------

  validates_presence_of :email, :password
  validates_uniqueness_of :email


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

  private

  def create_api_key
    return if api_key.present?
    self.api_key = SecureRandom.uuid
  end
end
