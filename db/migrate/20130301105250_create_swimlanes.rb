class CreateSwimlanes < ActiveRecord::Migration
  def change
    create_table :swimlanes do |t|
      t.references :board, index: true
      t.integer :ordering, default: 0
      t.integer :limit
      t.boolean :default, null: false, default: false
      t.string :title
      t.hstore :criteria, null: false, default: {}

      t.timestamps
    end
  end
end
