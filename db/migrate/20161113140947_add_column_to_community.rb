class AddColumnToCommunity < ActiveRecord::Migration[5.0]
  def change
    add_column :communities, :detail, :text
  end
end
