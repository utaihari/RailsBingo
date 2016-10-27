class CreateCardNumbers < ActiveRecord::Migration[5.0]
  def change
    create_table :card_numbers do |t|
      t.integer :bingo_card_id
      t.integer :number

      t.timestamps
    end
  end
end
