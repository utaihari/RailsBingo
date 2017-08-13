class AddColumnJoinCountBonusToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :join_count_bounus, :double, default: 0
  end
end
