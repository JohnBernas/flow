class Swimlane < ActiveRecord::Base
  SWIMLANIZERS = %w[tags status priority requester_id organization_id group_id]

  include RankedModel
  ranks :ordering, with_same: :board_id

  belongs_to :board
  has_many :columns, through: :board
  has_many :stories

  default_scope -> { rank(:ordering) }

  def self.inbox
    find_by(default: true)
  end
end
