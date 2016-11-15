class ChangeDefaultToCommunity < ActiveRecord::Migration[5.0]
  def change
  	change_column :communities, :detail, :text, default: ""
  end
end
