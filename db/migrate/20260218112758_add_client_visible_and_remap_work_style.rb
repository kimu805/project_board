class AddClientVisibleAndRemapWorkStyle < ActiveRecord::Migration[8.0]
  def up
    add_column :projects, :client_visible, :boolean, default: false, null: false
    Project.where(work_style: 1).update_all(work_style: 5)
  end

  def down
    Project.where(work_style: 5).update_all(work_style: 1)
    Project.where(work_style: [2, 3, 4]).update_all(work_style: 1)
    remove_column :projects, :client_visible
  end
end
