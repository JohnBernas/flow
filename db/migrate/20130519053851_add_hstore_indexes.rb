class AddHstoreIndexes < ActiveRecord::Migration
  def up
    %w[swimlanes columns].each do |table|
      execute "CREATE INDEX #{table}_criteria ON #{table} USING GIN(criteria)"
    end

    %w[boards stories].each do |table|
      execute "CREATE INDEX #{table}_data ON #{table} USING GIN(data)"
    end

    execute 'CREATE INDEX stories_remote ON stories USING GIN(remote)'
  end

  def down
    %w[boards stories].each do |table|
      execute "DROP INDEX #{table}_data"
    end

    %w[swimlanes columns].each do |table|
      execute "DROP INDEX #{table}_criteria"
    end

    execute 'DROP INDEX stories_remote'
  end
end
