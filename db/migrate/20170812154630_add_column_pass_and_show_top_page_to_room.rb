class AddColumnPassAndShowTopPageToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :pass, :string, default: ""
    add_column :rooms, :show_top_page, :boolean, default: true
  end
end
