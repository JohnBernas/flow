class UpdatePivotalWorker
  include Sidekiq::Worker

  def perform(story_id)
    story = Story.find(story_id)
    Pivotal.new(id: story.pid, project_id: story.board.project_id).update_remote
  end
end
