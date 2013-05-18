class UpdateStoryWorker
  include Sidekiq::Worker

  def perform(payload)
    story = Story.find(payload['id'])

    story.update_attribute(:column_id, payload['column_id'])
    story.update_attribute(:priority_position, payload['priority'])

    State.new(story).assign_attributes
    Label.new(story).assign_attributes
    story.save

    UpdatePivotalWorker.perform_async(story.id)
  end
end
