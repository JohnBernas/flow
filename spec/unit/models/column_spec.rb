require 'spec_helper'

describe Column do
  Given(:data) { { 'labels' => 'c.customer1', 'limit' => 3 } }
  Given(:board) { create(:board) }

  context '.inbox' do
    Given!(:inbox) { create(:column, board: board, data: { 'default' => 'true' }) }
    Then { expect(board.columns.inbox).to eq inbox }
  end

  context '#overflowing?' do
    Given!(:column) { create(:column, board: board, data: data) }

    context 'for <' do
      Given { create_list(:story, 2, column: column) }
      Then { expect(column.overflowing?).to be_false }
    end

    context 'for ==' do
      Given { create_list(:story, 3, column: column) }
      Then { expect(column.overflowing?).to be_false }
    end

    context 'for >' do
      Given { create_list(:story, 4, column: column) }
      Then { expect(column.overflowing?).to be_true }
    end
  end

  context '#at_capacity?' do
    Given!(:column) { create(:column, board: board, data: data) }

    context 'for <' do
      Given { create_list(:story, 2, column: column) }
      Then { expect(column.at_capacity?).to be_false }
    end

    context 'for ==' do
      Given { create_list(:story, 3, column: column) }
      Then { expect(column.at_capacity?).to be_true }
    end

    context 'for >' do
      Given { create_list(:story, 4, column: column) }
      Then { expect(column.at_capacity?).to be_false }
    end
  end

  context '#move_stories_to_inbox_column' do
    Given!(:column) { create(:column, board: board, data: data) }
    Given!(:inbox) { create(:column, board: board, data: { 'default' => 'true' }) }
    Given!(:story) { create(:story, column: column) }
    When { column.move_stories_to_inbox_column }
    Then { expect(column.reload.stories).to be_empty }
    Then { expect(inbox.reload.stories).to eq [story] }
  end
end
