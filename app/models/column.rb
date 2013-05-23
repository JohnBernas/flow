class Column < ActiveRecord::Base
  include RankedModel

  belongs_to :board
  has_many :stories

  ranks :display, with_same: :board_id

  store_accessor :data, :default, :limit, :state, :label
  before_destroy :move_stories_to_inbox_column
  scope :ordered, -> { rank(:display) }

  def self.inbox
    where("data -> 'default' = 'true'").first
  end

  def overflowing?
    limit && stories.count > limit.to_i
  end

  def at_capacity?
    limit && stories.count == limit.to_i
  end

  def move_stories_to_inbox_column
    stories.each(&:assign_to_inbox_column)
  end
end
