class Column < ActiveRecord::Base
  include RankedModel

  belongs_to :board
  has_many :swimlanes, through: :board
  has_many :stories

  ranks :display, with_same: :board_id

  before_destroy :move_stories_to_inbox_column
  default_scope -> { rank(:display) }

  def self.inbox
    where(default: true).first || first
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
