class CreateSwimlanes < ActiveRecord::Migration
  def change
    create_table :swimlanes do |t|
      t.string :title
      t.integer :horizontal, default: 0
      t.references :board, index: true
      t.hstore :data, null: false, default: {}

      t.timestamps
    end
  end
end
