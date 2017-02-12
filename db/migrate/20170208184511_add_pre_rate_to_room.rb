class AddPreRateToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :pre_rate, :integer, default: 0
  end
end
