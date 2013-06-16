class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.integer :recipe_id
      t.integer :user_id
      t.string :action
      t.timestamps
    end

    add_index :permissions, :recipe_id
    add_index :permissions, :user_id
  end

  def self.down
    drop_table :permissions
  end
end
