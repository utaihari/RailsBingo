class AddColumnDateAndPrizeToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :date, :datetime
    add_column :rooms, :prize, :string, default: ""
  end
end
