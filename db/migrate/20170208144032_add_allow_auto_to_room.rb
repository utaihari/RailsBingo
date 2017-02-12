class AddAllowAutoToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :allow_auto, :boolean, default: true
  end
end
