class Label
  attr_reader :labels, :story

  def initialize(story)
    @story  = story
    @labels = tracker['labels'].split(',') rescue []
  end

  def to_a
    labels
  end

  def eq?(other_labels)
    labels.uniq.sort == other_labels.split(',').uniq.sort
  end

  def set_for_column(column)
    remove_column_labels
    add of_column(column)
    save(false)
  end

  def matching_current_state
    labels & story.board.columns.where("columns.data -> 'state' = ?",
      State.new(story).to_s).pluck("columns.data -> 'label'").compact.uniq
  end

  def of_column(column)
    column.data['label']
  end

  def columnizers
    labels.grep(/\As\.\S+/i)
  end

  def swimlaneizers
    labels & story.board.swimlanes.labels
  end

  def has?(lbls)
    lbls = [lbls].flatten.uniq
    lbls.all?{ |lbl| lbl && labels.grep(lbl).any? }
  end

  def add(lbls)
    lbls = [lbls].flatten.uniq
    lbls.each do |lbl|
      @labels << lbl unless labels.include? lbl
    end
    save(false)
  end

  def add!(lbls)
    add(lbls)
    save
  end

  def remove_column_labels
    @labels = labels.reject{ |label| columnizers.include?(label) }
  end

  def remove_column_labels!
    remove_column_labels
    save
  end

  def save(persist = true)
    attributes = tracker.merge('labels' => labels.join(','))
    persist ? story.update_attributes(tracker: attributes) : story.assign_attributes(tracker: attributes)
  end

  def assign_attributes
    column_label = of_column(story.column)

    if column_label && ! self.has?(column_label)
      State.new(story).started(if: :accepted)
      remove_column_labels
      add(column_label)
    else
      remove_column_labels
    end
  end

private

  def tracker
    @story.tracker
  end
end
