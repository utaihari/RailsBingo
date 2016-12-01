class AddTypeToItem < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :type, :integer, default:0
  end
end
