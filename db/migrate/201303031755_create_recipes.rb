class CreateRecipes < ActiveRecord::Migration
  def self.up
    create_table :recipes do |t|
      t.integer :app_id
      t.string :name
      t.text :content
      t.timestamps
    end

    add_index :recipes, :app_id
    add_index :recipes, :name
  end

  def self.down
    drop_table :recipes
  end
end
