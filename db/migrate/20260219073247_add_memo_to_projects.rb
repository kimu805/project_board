class AddMemoToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :memo, :text
  end
end
