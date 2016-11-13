class AddDetailToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :detail, :text
  end
end
