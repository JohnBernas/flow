module BoardsController
  class Show < ApplicationController
    expose(:board) { Board.find_by_id(params[:id]) }
    expose(:dashboard) { params[:dashboard] ? true : false }
  end

  class Synchronize < ApplicationController
    def call
      SynchronizationWorker.perform_async(params[:id], remote: true)
      redirect_to board_url(params[:id])
    end
  end
end
