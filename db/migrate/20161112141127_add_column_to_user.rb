class AddColumnToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :isGuest, :boolean, default: false
  end
end
