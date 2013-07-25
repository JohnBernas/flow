class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.integer :priority, default: 0
      t.references :column, index: true
      t.hstore :data, null: false, default: {}
      t.hstore :remote, null: false, default: {}

      t.timestamps
    end
  end
end
