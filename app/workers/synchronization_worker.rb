class SynchronizationWorker
  include Sidekiq::Worker

  def perform(board_id, opts = {})
    board = Board.find(board_id)
    board.synchronize if opts['remote'] || board.stories.count == 0

    WebsocketRails[:stories].trigger(:redraw, board.stories.ordered.reload)
  end
end
