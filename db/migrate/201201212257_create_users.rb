class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email
      t.string :password, :default => nil
      t.string :api_key
      # reset password
      t.string :reset_password_token, :default => nil
      t.datetime :reset_password_token_expires_at, :default => nil
      t.datetime :reset_password_email_sent_at, :default => nil
      t.timestamps
    end

    add_index :users, :reset_password_token
  end

  def self.down
    drop_table :users
  end
end
