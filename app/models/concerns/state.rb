class State
  attr_reader :state, :story

  def initialize(story)
    @story = story
    @state = tracker['current_state']
  end

  def to_s
    state
  end

  def started(opts = {})
    @state = 'started' if ! opts.has_key?(:if) || state == opts[:if].to_s
  end

  def started!(opts = {})
    started(opts)
    save
  end

  def set_for_column(column)
    @state = of_column(story.column)
    save(false)
  end

  def matching_column(opts = {})
    cols = story.column.board.columns
    cols = cols.where("data -> 'state' = '#{state}'")
    cols = cols.reject { |c| !!c.data['label'] } if opts[:without_labels]
    cols.first
  end

  def of_column(column)
    column.data['state']
  end

  def save(persist = true)
    story.current_state = state
    story.save if persist
  end

  def assign_attributes
    column_state = of_column(story.column)

    if state != column_state
      set_started_at_if_missing
      @state = column_state
      save(false)
    end
  end

private

  def set_started_at_if_missing
    story.started_at = Time.zone.now unless story.started_at
  end

  def tracker
    @story.tracker
  end
end
