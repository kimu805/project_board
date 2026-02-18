class RemapWorkStyle < ActiveRecord::Migration[8.0]
  def up
    # work_style: 1 (remote) → 5 (full_remote) にリマップ
    Project.where(work_style: 1).update_all(work_style: 5)
  end

  def down
    Project.where(work_style: 5).update_all(work_style: 1)
    Project.where(work_style: [2, 3, 4]).update_all(work_style: 1)
  end
end
