require 'spec_helper'

describe Story do
  Given(:board) { create(:board) }
  Given(:column) { create(:column, board: board) }
  Given(:story) { create(:story, column: column) }

  context '#as_json' do
    When(:json) { JSON.parse(story.to_json) }
    Then { expect(json.keys).to eq %w[id column_id remote pid sid labels] }
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

  context '#pid' do
    Given { story.stub_chain(:remote, :[]).with('id').and_return('123456') }
    Then  { expect(story.pid).to eq '123456' }
  end

  context '#sid' do
    Given(:swimlane) { create(:swimlane) }
    Given { story.stub(:swimlane).and_return(swimlane) }
    Then  { expect(story.sid).to eq swimlane.id }
  end

  context '#swimlane' do
    Given(:data) { { 'labels' => 'client1,client2' } }
    Given(:label) { double('Label') }
    Given { Label.stub(:new).with(story).and_return(label) }

    context 'with matching labels' do
      Given!(:swimlane) { create(:swimlane, board: board, data: data) }
      Given { label.stub(:swimlaneizers).and_return(%w[client1]) }
      Then { expect(story.swimlane).to eq swimlane }
    end

    context 'without matching labels' do
      Given!(:inbox) { create(:swimlane, board: board, data: { default: true }) }
      Given { label.stub(:swimlaneizers).and_return(%w[]) }
      Then { expect(story.swimlane).to eq inbox }
    end

    context 'without matching labels and no default swimlane' do
      Given!(:swimlane) { create(:swimlane, board: board) }
      Given { label.stub(:swimlaneizers).and_return(%w[]) }
      Then { expect(story.swimlane).to eq swimlane }
    end
  end

  context '#assign_to_inbox_column' do
    Given!(:inbox) { create(:column, board: board, data: { default: true }) }
    When { story.assign_to_inbox_column }
    Then { expect(story.column).to eq inbox }
  end
end
