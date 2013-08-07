require 'spec_helper'

describe Story do
  Given(:board) { create(:board, data: { host: ENV['ZENDESK_HOST'] }) }
  Given!(:column) { create(:column, board: board, criteria: { tags: 'col1' }) }
  Given!(:swimlane) { create(:swimlane, board: board) }

  Given(:ticket) { double() }

  Given do
    ticket.stub(:url).and_return("http://#{ENV['ZENDESK_HOST']}")
    ticket.stub(:id).and_return(rand)
    ticket.stub(:is_a?).with(ZendeskAPI::Ticket).and_return(true)
    ticket.stub(:attributes).and_return('tags' => 'col1')
  end

  Given(:story) { Zendesk.new(ticket).story }

  context '#as_json' do
    When(:json) { JSON.parse(story.to_json) }
    Then { expect(json.keys).to eq %w[id column_id swimlane_id remote remote_id] }
  end

  context '#board' do
    Then  { expect(story.board).to eq board }
  end

  context '#labels' do
    context 'without labels' do
      Given { story.stub_chain(:remote, :[]).with('tags').and_return(nil) }
      Then  { expect(story.labels).to eq [] }
    end

    context 'with two labels' do
      Given { story.stub_chain(:remote, :[]).with('tags').and_return('label1,label2') }
      Then  { expect(story.labels).to eq %w[label1 label2] }
    end
  end

  context '#remote_id' do
    Given { story.stub_chain(:remote, :[]).with('id').and_return('123456') }
    Then  { expect(story.remote_id).to eq '123456' }
  end

  context '#swimlane_id' do
    Given { story.stub(:swimlane).and_return(swimlane) }
    Then  { expect(story.swimlane_id).to eq swimlane.id }
  end

  context '#swimlane' do
    context '' do
      Given(:swimlane) { create(:swimlane, board: board, criteria: { 'tags' => 'client1,client2' }) }

      context 'with matching tags' do
        Given(:ticket) do
          story = double()
          story.stub(:url).and_return("http://#{ENV['ZENDESK_HOST']}")
          story.stub(:id).and_return(rand)

          story.stub(:is_a?).with(ZendeskAPI::Ticket).and_return(true)
          story.stub(:attributes).and_return('tags' => 'client1')
          Zendesk.new(story)
        end

        Then { expect(ticket.story.swimlane).to eq swimlane }
      end

      context 'without matching tags' do
        Then { expect(story.swimlane).to eq swimlane }
      end
    end

    context 'without matching labels and no default swimlane' do
      Given!(:swimlane) { create(:swimlane, board: board) }
      Then { expect(story.swimlane).to eq swimlane }
    end
  end

  context '#assign_to_inbox_column' do
    Given!(:inbox) { create(:column, board: board, default: true) }
    When { story.assign_to_inbox_column }
    Then { expect(story.column).to eq inbox }
  end
end
