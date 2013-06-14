require 'spec_helper'

describe Activity do
  Given(:new_story_activity) do
    {"activity"=>{"id"=>363738367, "version"=>1076, "event_type"=>"story_update", "occurred_at"=>"2013-05-24T14:30:51+00:00", "author"=>"Jean Mertz", "project_id"=>769661, "description"=>"Jean Mertz edited \"story test 2\"", "stories"=>[{"id"=>50518297, "url"=>"http://www.pivotaltracker.com/services/v3/projects/769661/stories/50518297", "current_state"=>"unstarted"}]}, "format"=>"xml", "action"=>"call", "controller"=>"remote_controller/activity"}
  end
end
