module RemoteController
  class Activity < ApplicationController
    skip_before_filter :verify_authenticity_token

    def call
      RemoteActivityWorker.perform_async(params)
      head 200
    end
  end
end
