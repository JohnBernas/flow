require 'spec_helper'

describe Board do
  Given!(:board) { create(:board, data: { zendesk_account: 'kabisa.zendesk.com' }) }
  Given!(:column) { create(:column, board: board, data: { default: true }) }

  context '#synchronize' do
    context 'removes solved/closed Zendesk tickets' do
      Given!(:orphaned_story) { create(:story, column: column) }
      When { VCR.use_cassette(:remote_tickets) { board.synchronize } }
      Then { expect(board.stories.where("remote -> 'status' = 'open'")).not_to be_empty }
      And { expect(board.stories.where("remote -> 'status' = 'closed'")).to be_empty }
      And { expect(board.stories.where(id: orphaned_story.id)).to be_empty }
    end
  end

  context '#remote_stories' do
    Given(:closed_ticket) { VCR.use_cassette(:closed_ticket) { Zendesk.new(200).story } }
    Given(:new_ticket) { VCR.use_cassette(:new_ticket) { Zendesk.new(1192).story } }

    Given(:remote_stories) do
      VCR.use_cassette(:remote_tickets) { board.remote_stories }
    end

    Then { expect(remote_stories.any? { |s| s['id'] == closed_ticket.remote['id'] }).to be_false }
    Then { expect(remote_stories.any? { |s| s['id'] == new_ticket.remote['id'] }).to be_true }
  end
end
