class AddHstoreIndexes < ActiveRecord::Migration
  def up
    %w[boards swimlanes columns stories].each do |table|
      execute "CREATE INDEX #{table}_data ON #{table} USING GIN(data)"
    end

    execute 'CREATE INDEX stories_tracker ON stories USING GIN(tracker)'
  end

  def down
    %w[boards swimlanes columns stories].each do |table|
      execute "DROP INDEX #{table}_data"
    end

    execute 'DROP INDEX stories_tracker'
  end
end
