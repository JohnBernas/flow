class RemoteActivityWorker
  include Sidekiq::Worker

  def perform(params)
    activity = Activity.new(params)
    activity.stories.each do |story_activity|
      pivotal = Pivotal.new(id: story_activity['id'], project_id: activity.project_id)

      next unless pivotal.story_changed?(activity.occurred_at)

      details = Pivotal.create_or_update_from_remote(pivotal.remote)
      WebsocketRails[:stories].trigger(:story_update, details)
    end
  end
end
