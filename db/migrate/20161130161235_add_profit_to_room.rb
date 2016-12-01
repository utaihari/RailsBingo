class AddProfitToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :profit, :integer, default: 0
  end
end
