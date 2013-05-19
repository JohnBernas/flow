class Activity
  attr_reader :activity, :project_id, :occurred_at, :stories

  def initialize(params)
    @activity   = params['activity'].with_indifferent_access
    @project_id = activity[:project_id]
    @occurred_at = activity[:occurred_at]
    @stories    = activity[:stories]
  end
end
