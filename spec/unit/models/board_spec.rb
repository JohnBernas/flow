require 'spec_helper'

describe Board do
  Given(:board) { create(:board, data: { project_id: 769661 }) }
  Given(:column) { create(:column, board: board, data: { default: true }) }
  Given(:project_id) { '769661' }
  Given(:remote_story_id) { '45428551' }
  Given(:icebox_story_id) { '45428597' }

  context '#synchronize' do
    context 'removes stories no longer in Pivotal Tracker' do
      Given!(:orphaned_story) { create(:story, column: column) }
      When { VCR.use_cassette(:remote_stories) { board.synchronize } }
      Then { expect(board.stories.where("tracker -> 'id' = ?", remote_story_id)).not_to be_empty }
      And { expect(board.stories.where("tracker -> 'id' = ?", icebox_story_id)).to be_empty }
      And { expect(board.stories.where(id: orphaned_story.id)).to be_empty }
    end
  end

  context '#remote_stories' do
    Given(:icebox_story) { VCR.use_cassette(:icebox_pivotal_story) { Pivotal.new(id: icebox_story_id, project_id: project_id) } }
    Given(:new_story) { VCR.use_cassette(:new_pivotal_story) { Pivotal.new(id: remote_story_id, project_id: project_id) } }

    context '(icebox: true)' do
      Given(:remote_stories) do
        VCR.use_cassette(:remote_stories) do
          board.remote_stories(icebox: true)
        end
      end

      Then { expect(remote_stories.any? { |s| s.id == icebox_story.remote.id }).to be_true }
      Then { expect(remote_stories.any? { |s| s.id == new_story.remote.id }).to be_true }
    end

    context '(icebox: false)' do
      Given(:remote_stories) do
        VCR.use_cassette(:remote_stories) do
          board.remote_stories(icebox: false)
        end
      end

      Then { expect(remote_stories.any? { |s| s.id == icebox_story.remote.id }).to be_false }
      Then { expect(remote_stories.any? { |s| s.id == new_story.remote.id }).to be_true }
    end
  end
end
