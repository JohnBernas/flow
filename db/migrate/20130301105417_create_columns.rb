class CreateColumns < ActiveRecord::Migration
  def change
    create_table :columns do |t|
      t.string :title
      t.integer :display, default: 0
      t.references :board, index: true
      t.hstore :data, null: false, default: {}

      t.timestamps
    end
  end
end
