class Board < ActiveRecord::Base
  has_many :swimlanes, dependent: :destroy
  has_many :columns, dependent: :destroy
  has_many :stories, through: :columns

  store_accessor :data, :project_id

  def synchronize
    updated_stories = remote_stories.each_with_object([]) do |remote, arr|
      arr << Zendesk.new(remote).story
    end

    stories.where('stories.id NOT IN (?)', updated_stories.map(&:id)).destroy_all
  end

  def remote_stories
    Zendesk.client.search(query: 'type:ticket status<solved').to_a
  end
end
