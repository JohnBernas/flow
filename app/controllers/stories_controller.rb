module StoriesController
  class Index < ApplicationController

    def call
      board = Board.find(params[:board_id])
      board.synchronize if board.stories.count == 0

      render json: board.stories.active.ordered
    end
  end
end
