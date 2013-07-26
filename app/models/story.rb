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
    inbox = board.columns.inbox
    Label.new(self).set_for_column(inbox)
    State.new(self).set_for_column(inbox)
    update_attributes(column: inbox, priority_position: :last)
  end

private

  def matched_swimlane
    matches = {}
    # loop over each attribute of this story
    remote.each do |key, value|
      next unless Swimlane::SWIMLANIZERS.include?(key)

      swimlanes = Swimlane.none
      swimlanes = board.swimlanes
        .where("string_to_array(swimlanes.criteria -> '#{key}', ',') && ?",
        "{#{value}}")

      # loop over all matches swimlanes, and add them with rankings
      swimlanes.each do |swimlane|
        if matches[swimlane.id]
          matches[swimlane.id][:ranking] += 1
        else
          matches[swimlane.id] = { swimlane: swimlane, ranking: 1 }
        end
      end
    end

    swimlane = nil
    # move through all rankings, going up the stack, searching unique
    matches.any? && matches.sort_by{ |_,v| v[:ranking] }.each do |match|
      next if matches.flatten.count(match.last[:ranking]) != 1
      swimlane = match.last[:swimlane]
    end

    swimlane || board.swimlanes.inbox || board.swimlanes.first
  end
end
