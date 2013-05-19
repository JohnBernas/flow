class Pivotal

  def self.create_or_update_from_remote(remote)
    remote = get_remote(remote)
    board = Board.where("data -> 'project_id' = ?::text", remote.project_id).first
    story = get_story(remote).first_or_create(column: board.columns.inbox)
    story.update_attribute :priority_position, :last

    return story if new(remote, story).update_from_remote
  end

  def self.get_story(remote)
    remote = get_remote(remote)
    board = Board.where("data -> 'project_id' = ?::text", remote.project_id).first
    board.stories.where("tracker -> 'id' = ?::text", remote.id)
  end

  def self.get_remote(remote)
    if remote.respond_to?(:id)
      remote
    elsif remote.is_a?(Hash)
      remote = remote.with_indifferent_access
      PivotalTracker::Story.find(remote[:id], remote[:project_id])
    else
      raise 'Remote needs to be PivotalTracker instance or Hash with id and project_id'
    end
  end

  attr_reader :remote, :story

  def initialize(remote, story = nil)
    @remote = remote.respond_to?(:id) ? remote : Pivotal.get_remote(remote)
    @story = story.respond_to?(:id) ? story : Pivotal.get_story(remote).first
    raise 'Story not found, it requires a tracker -> id hash object' unless @story
  end

  def update_from_remote
    story.assign_attributes(tracker: attributes(remote))
    story.assign_attributes(column: column_based_on_story_and_labels)
    story.save
  end

  def update_remote
    pivotal_sanity_check
    remote.update(story.tracker)
  end

  def story_changed?(occurred_at)
    return true unless story # If it's a new story, it has changed...
    remote_is_newer?(occurred_at) && attributes_changed?(:current_state, :labels)
  end

private

  def pivotal_sanity_check
    story.update_attributes(estimate: '0') if story.estimate == '-1'
  end

  def attributes_changed?(*attributes)
    remote_details = attributes(remote)
    local_details = story.tracker

    labels_changed?(remote_details['labels'], attributes.delete(:labels)) ||
    attributes.any? { |a| remote_details[a.to_s] != local_details[a.to_s] }
  end

  def labels_changed?(labels, do_check)
    do_check && !Label.new(story).eq?(labels)
  end

  def remote_is_newer?(occurred_at)
    occurred_at.to_datetime > story.updated_at.to_datetime
  end

  def column_based_on_story_and_labels
    state = State.new(story)

    # get all columns on the board
    columns = board.columns

    # check if story state matches a column state
    if state.matching_column
      columns = columns.where("data -> 'state' = ?", state.to_s)
    end

    # check for columns that match current state, and have column labels
    if labels = Label.new(story).matching_current_state and labels.any?
      columns = columns.where("string_to_array(data -> 'label', ',') <@ '{#{labels.join(',')}}'")
    # if none found, find column(s) without any labels, matching current state
    else
      columns = columns.where("NOT data ? 'label'")
    end

    # get correct column, or assign to inbox
    state.matching_column || labels.any? ? columns.first : columns.inbox
  end

  def attributes(remote_story)
    remote_story.instance_variables.each_with_object({}) do |key, hash|
      var = remote_story.instance_variable_get(key)
      var.split!(',') if key == '@:labels'
      hash[key[1..-1]] = var
    end
  end

  def board(project_id = nil)
    @board ||= Board.where("data -> 'project_id' = ?::text", project_id ||
      story.board.project_id).first
  end

  def remote
    @remote ||= PivotalTracker::Project.find(board.project_id)
  end
end
