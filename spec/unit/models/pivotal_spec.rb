require 'spec_helper'

describe Pivotal do
  Given(:project_id) { '769661' }
  Given(:remote_story_id) { '45428551' }
  Given(:icebox_story_id) { '45428597' }
  Given!(:board)   { create(:board, data: { project_id: 769661 }) }
  Given(:column)  { create(:column, board: board) }
  Given(:story)   { create(:story, column: column) }

  describe '.get_remote' do
    describe 'when passing in a hash' do
      When(:remote) do
        VCR.use_cassette(:new_activity_story) do
          Pivotal.get_remote(id: remote_story_id, project_id: project_id)
        end
      end

      Then { expect(remote).to be_a PivotalTracker::Story }
    end

    describe 'when passing in a PivotalTracker::Story instance' do
      Given(:pivotal_tracker_instance) { double() }
      Given { pivotal_tracker_instance.stub(:id) { 1337 } }
      When(:remote) { Pivotal.get_remote(pivotal_tracker_instance) }
      Then { expect(remote.id).to eq 1337 }
    end
  end

  describe '#initialize' do
    When(:pivotal) do
      VCR.use_cassette(:new_pivotal_story) { Pivotal.new(id: remote_story_id, project_id: project_id) }
    end

    describe 'for new pivotal story' do
      Then { expect(pivotal.story).to be_nil }
      Then { expect(pivotal.remote).to be_a PivotalTracker::Story }
    end

    describe 'for an existing pivotal story' do
      Given!(:story) { create(:story, column: column, tracker: { id: remote_story_id }) }
      Then { expect(pivotal.story).to eq story }
      Then { expect(pivotal.remote).to be_a PivotalTracker::Story }
    end
  end

  describe '#icebox_story?' do
    describe 'for icebox story' do
      Given(:pivotal) do
        VCR.use_cassette(:icebox_pivotal_story) { Pivotal.new(id: icebox_story_id, project_id: project_id) }
      end
      Then { expect(pivotal.remote.current_state).to eq 'unscheduled' }
      And { expect(pivotal.icebox_story?).to be_true }
    end

    describe 'for non-icebox story' do
      Given(:pivotal) do
        VCR.use_cassette(:remote_story_id) { Pivotal.new(id: remote_story_id, project_id: project_id) }
      end
      Then { expect(pivotal.remote.current_state).to eq 'delivered' }
      And { expect(pivotal.icebox_story?).to be_false }
    end
  end
end
