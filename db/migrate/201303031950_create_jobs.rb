class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.integer :recipe_id
      t.string :task
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :success
      t.text :log
      t.text :error
      t.text :config

      t.timestamps
    end

    add_index :jobs, :recipe_id
  end

  def self.down
    drop_table :jobs
  end
end
