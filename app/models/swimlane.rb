class Swimlane < ActiveRecord::Base
  include RankedModel
  ranks :horizontal, with_same: :board_id

  belongs_to :board
  has_many :columns, through: :board

  store_accessor :data, :limit
  default_scope -> { rank(:horizontal) }

  def self.inbox
    where("data -> 'default' = 'true'").first
  end

  def self.labels
    select("(data -> 'labels') as labels").to_a.each_with_object([]){
        |l,o| o << l['labels'] }.compact.join(',').split(',')
  end

  def labels
    data['labels'] ? data['labels'].split(',') : []
  end

  def stories
    stories = board.stories.joins("INNER JOIN swimlanes ON
      ((string_to_array(swimlanes.data -> 'labels', ','))
      && (string_to_array(stories.tracker -> 'labels', ',')))")

    if labels.any?
      stories.where('swimlanes.id = ?', id)
    else
      board.stories.where("stories.id NOT IN (?)", stories)
    end
  end
end
