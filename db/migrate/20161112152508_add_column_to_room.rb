class AddColumnToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :AllowGuest, :boolean, default: false
  end
end
