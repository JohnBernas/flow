require 'spec_helper'

describe Swimlane do
  Given(:board) { create(:board) }
  Given!(:swimlane) { create(:swimlane, board: board, data: { 'labels' => 'swim1,client1' }) }

  context '.inbox' do
    Given!(:inbox) { create(:swimlane, board: board, data: { 'default' => 'true' }) }
    Then { expect(board.swimlanes.inbox).to eq inbox }
  end

  context '#stories' do
    Given(:column) { create(:column, board: board) }
    Given(:story1) { create(:story, column: column, remote: { 'tags' => 'swim1' }) }
    Given { create(:story, column: column, remote: { 'tags' => 'client3' }) }
    Given { create(:story, column: column) }

    Then { expect(swimlane.stories).to eq [story1] }
  end
end
