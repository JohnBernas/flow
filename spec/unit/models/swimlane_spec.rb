require 'spec_helper'

describe Swimlane do
  Given(:board) { create(:board, data: { host: ENV['ZENDESK_HOST'] }) }
  Given!(:inbox) { create(:swimlane, board: board, default: true) }
  Given!(:swimlane) { create(:swimlane, board: board, criteria: { 'tags' => 'swim1,client1' }) }

  context '.inbox' do
    Then { expect(board.swimlanes.inbox).to eq inbox }
  end

  context '#stories' do
    Given(:column) { create(:column, board: board) }
    Given(:ticket) do
      story = double()
      story.stub(:url).and_return("http://#{ENV['ZENDESK_HOST']}")
      story.stub(:id).and_return(rand)

      story.stub(:is_a?).with(ZendeskAPI::Ticket).and_return(true)
      story.stub(:attributes).and_return('tags' => 'swim1')
      Zendesk.new(story)
    end

    Given do
      story = double()
      story.stub(:url).and_return("http://#{ENV['ZENDESK_HOST']}")
      story.stub(:id).and_return(rand)

      story.stub(:is_a?).with(ZendeskAPI::Ticket).and_return(true)
      story.stub(:attributes).and_return('tags' => 'client3')
      Zendesk.new(story)

      story.stub(:attributes).and_return({})
      Zendesk.new(story)
    end

    Then { expect(swimlane.stories).to eq [ticket.story] }
  end
end
