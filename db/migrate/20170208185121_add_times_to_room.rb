class AddTimesToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :times, :integer, default: 0
  end
end
