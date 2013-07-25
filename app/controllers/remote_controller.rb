module RemoteController
  class Activity < ApplicationController
    skip_before_filter :verify_authenticity_token

    def call
      zd = Zendesk.new(params['id'])
      WebsocketRails[:stories].trigger(:story_update, zd.story)

      head 200
    end
  end
end
