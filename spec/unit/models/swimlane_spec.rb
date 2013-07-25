require 'spec_helper'

describe Swimlane do
  Given(:board) { create(:board) }
  Given!(:swimlane) { create(:swimlane, board: board, data: { 'labels' => 'swim1,client1' }) }

  context '.inbox' do
    Given!(:inbox) { create(:swimlane, board: board, data: { 'default' => 'true' }) }
    Then { expect(board.swimlanes.inbox).to eq inbox }
  end

  context '.labels' do
    Given { create(:swimlane, board: board, data: { 'labels' => 'client2' }) }
    Then  { expect(board.swimlanes.labels.sort).to eq %w[swim1 client1 client2].sort }
  end

  context '#labels' do
    Then { expect(swimlane.labels.sort).to eq %w[swim1 client1].sort }
  end

  context '#stories' do
    Given(:column) { create(:column, board: board) }
    Given(:story1) { create(:story, column: column, remote: { 'tags' => 'swim1' }) }
    Given { create(:story, column: column, remote: { 'tags' => 'client3' }) }
    Given { create(:story, column: column) }

    Then { expect(swimlane.stories).to eq [story1] }
  end
end
