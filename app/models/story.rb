class Story < ActiveRecord::Base
  CRITERIA = %w[tags status priority requester_id organization_id group_id]

  include RankedModel
  ranks :priority, with_same: [:column_id, :swimlane_id]
  belongs_to :column

  scope :ordered, ->{ order(:column_id, :priority) }

  def as_json(options)
    super(only: %i[id column_id swimlane_id remote], methods: 'remote_id')
  end

  def board
    column.board
  end

  def labels
    remote['tags'] ? remote['tags'].split(',') : []
  end

  def swimlane
    Swimlane.find_by(id: swimlane_id) || board.swimlanes.inbox
  end

  def remote_id
    remote['id']
  end

  def assign_to_inbox_column
    update_attributes(column: board.columns.inbox, priority_position: :last)
  end
end
