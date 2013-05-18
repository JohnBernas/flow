class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :title
      t.hstore :data, null: false, default: {}

      t.timestamps
    end
  end
end
