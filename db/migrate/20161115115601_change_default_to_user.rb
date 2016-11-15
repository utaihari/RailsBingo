class ChangeDefaultToUser < ActiveRecord::Migration[5.0]
  def change
  	change_column :users, :detail, :text, default: ""
  end
end
