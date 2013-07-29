class Story < ActiveRecord::Base
  include RankedModel
  ranks :priority, with_same: [:column_id, :swimlane_id]

  after_save -> { update_column(:swimlane_id, matched_swimlane.id) }

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

  def remote_id
    remote['id']
  end

  def assign_to_inbox_column
    update_attributes(column: board.columns.inbox, priority_position: :last)
  end
end
