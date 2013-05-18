module BoardsController
  class Show < ApplicationController
    expose(:board) { Board.find_by_id(params[:id]) }
  end

  class Synchronize < ApplicationController
    def call
      SynchronizationWorker.perform_async(params[:id], remote: true)
      head 200
    end
  end
end
