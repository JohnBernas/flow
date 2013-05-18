require 'spec_helper'

describe Story do
  Given(:board) { create(:board) }
  Given(:column) { create(:column, board: board) }
  Given(:story) { create(:story, column: column) }

  context '#as_json' do
    When(:json) { JSON.parse(story.to_json) }
    Then { expect(json.keys).to eq %w[id column_id tracker pid sid labels] }
  end

  context '#board' do
    Then  { expect(story.board).to eq board }
  end

  context '#labels' do
    context 'without labels' do
      Given { story.stub_chain(:tracker, :[]).with('labels').and_return(nil) }
      Then  { expect(story.labels).to eq [] }
    end

    context 'with two labels' do
      Given { story.stub_chain(:tracker, :[]).with('labels').and_return('label1,label2') }
      Then  { expect(story.labels).to eq %w[label1 label2] }
    end
  end

  context '#pid' do
    Given { story.stub_chain(:tracker, :[]).with('id').and_return('123456') }
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
    Then { expect(story.current_state).to eq inbox.state }
  end

  context '.scope_stories_based_on_swimlane_of_story' do
    Given(:data) { { 'labels' => 'client3,client4' } }

    context 'without any swimlanes' do
      Given!(:story_for_other_column) { create(:story, column: create(:column, board: board)) }
      Given!(:stories) { create_list(:story, 2, column: column).map(&:id) }
      When(:scope) { Story.scope_stories_based_on_swimlane_of_story(story) }
      Then { expect(stories + [story_for_other_column.id] - scope.map(&:id)).to be_empty }
    end

    context 'with a single swimlane' do
      Given(:tracker) { { 'labels' => 'client3' } }
      Given!(:swimlane) { create(:swimlane, board: board, data: data) }
      Given!(:stories_in_swimlane) { create_list(:story, 2, column: column, tracker: tracker) }

      When(:scope) { Story.scope_stories_based_on_swimlane_of_story(stories_in_swimlane.first) }
      Then { expect(scope.map(&:id)).to eq stories_in_swimlane.map(&:id) }
    end

    context 'with two swimlanes' do
      Given { create(:swimlane, board: board, data: data) }
      Given { create(:swimlane, board: board, data: { 'labels' => 'critical' }) }
      Given!(:client3_story_in_swimlane1) { create(:story, column: column, tracker: { 'labels' => 'client3' }) }
      Given!(:client4_story_in_swimlane1) { create(:story, column: column, tracker: { 'labels' => 'client4' }) }
      Given(:critical_story_in_swimlane2) { create(:story, column: column, tracker: { 'labels' => 'critical' }) }
      When(:swimlane1_stories) { Story.scope_stories_based_on_swimlane_of_story(client3_story_in_swimlane1) }
      When(:swimlane2_stories) { Story.scope_stories_based_on_swimlane_of_story(critical_story_in_swimlane2) }

      Then { expect(swimlane1_stories.map(&:id)).to eq [client3_story_in_swimlane1.id, client4_story_in_swimlane1.id] }
      Then { expect(swimlane2_stories.map(&:id)).to eq [critical_story_in_swimlane2.id] }
    end
  end
end
