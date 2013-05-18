class Activity
  attr_reader :activity

  def initialize(params)
    @activity = params['activity'].with_indifferent_access
    @project_id = activity[:project_id]
  end

  def stories
    activity[:stories]
  end
end
