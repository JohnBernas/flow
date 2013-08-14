module StoriesController
  class Index < ApplicationController::Action

    def call
      board = Board.find(params[:board_id])
      board.synchronize if board.stories.count == 0

      render json: board.stories.reload.ordered
    end
  end
end
