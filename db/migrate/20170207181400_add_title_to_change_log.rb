class AddTitleToChangeLog < ActiveRecord::Migration[5.0]
  def change
    add_column :change_logs, :title, :text
  end
end
