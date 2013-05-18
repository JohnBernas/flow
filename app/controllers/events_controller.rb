class EventsController < WebsocketRails::BaseController
  def story_update
    UpdateStoryWorker.perform_async(message)
  end
end
