class CreateChangeLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :change_logs do |t|
      t.text :body
      t.integer :log_type

      t.timestamps
    end
  end
end
