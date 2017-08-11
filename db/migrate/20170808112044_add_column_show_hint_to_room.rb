class AddColumnShowHintToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :show_hint, :boolean, default: false
  end
end
