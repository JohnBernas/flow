class Story < ActiveRecord::Base
  include RankedModel
  ranks :priority, with_same: :column_id, scope: :same_swimlane_as_story

  belongs_to :column

  attr_accessor :remote_labels, :remote_state
  store_accessor :data, :started_at
  store_accessor :remote, :current_state, :name, :url, :owned_by, :estimate

  scope :active, ->{ where("stories.remote -> 'status' NOT IN ('solved','closed')") }
  scope :ordered, ->{ order(:column_id, :priority) }
  scope :same_swimlane_as_story, ->(story) do
    # RankedModel gem also scopes before the record is saved. In this
    # case, the scope should be skipped, because `Label.new(story)` will
    # return nil (amongst other errors that could pop up).
    # See http://git.io/uWxSuQ
    story.id ? scope_stories_based_on_swimlane_of_story(story) : self
  end

  def as_json(options)
    super(only: [:id, :column_id, :remote], methods: %w[pid sid labels])
  end

  def board
    column.board
  end

  def labels
    remote['tags'] ? remote['tags'].split(',') : []
  end

  def pid
    remote['id']
  end

  def sid
    swimlane ? swimlane.id : nil
  end

  def swimlane
    if sllabels = Label.new(self).swimlaneizers and sllabels.any?
      board.swimlanes.where("string_to_array(data -> 'labels', ',') && ?",
        "{#{sllabels.join(',')}}").first
    else
      board.swimlanes.inbox || board.swimlanes.first
    end
  end

  def assign_to_inbox_column
    inbox = board.columns.inbox
    Label.new(self).set_for_column(inbox)
    State.new(self).set_for_column(inbox)
    update_attributes(column: inbox, priority_position: :last)
  end

private

  def self.scope_stories_based_on_swimlane_of_story(story)
    # find all stories that have swimlane labels
    labeled_stories = self.joins("INNER JOIN swimlanes ON
      ((string_to_array(swimlanes.data -> 'labels', ',')) &&
       (string_to_array(remote -> 'tags', ',')))")

    # get stories with same swimlane labels as current story
    if sllabels = Label.new(story).swimlaneizers.join(',') and sllabels.present?
      labeled_stories.where("string_to_array(swimlanes.data -> 'labels', ',') @> '{#{sllabels}}'")

    # get only stories without swimlane labels for 'default' swimlane...
    elsif labeled_stories.any?
      self.where("stories.id NOT IN (?)", labeled_stories)

    # ...or just all labels if no non-default swimlane stories exist in column
    else
      self.all
    end
  end
end
