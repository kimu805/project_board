class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :client_name
      t.integer :unit_price
      t.integer :work_style
      t.date :start_date
      t.date :end_date
      t.string :tech_stack
      t.integer :status
      t.integer :user_id, null: false
      t.text :memo

      t.timestamps
    end

    add_index :projects, :user_id
    add_foreign_key :projects, :users
  end
end
