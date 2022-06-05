class CreateResults < ActiveRecord::Migration[7.0]
  def change
    create_table :results do |t|
      t.string :name, null: false, default: ""
      t.integer :clicks, default: 0, null: false
      t.integer :time_taken, default: 0, null: false
      t.json :game_board
      t.float :high_score, default: 0, null: false

      t.timestamps
    end
  end
end
