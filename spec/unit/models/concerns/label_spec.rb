require 'spec_helper'

describe Label do
  Given(:labels)  { 's.pending,s.qa' }
  Given(:column)  { double() }
  Given(:story)   { double() }
  Given(:label)   { Label.new(story) }

  Given do
    story.stub(:remote) { { 'tags' => labels } }
    story.stub(:column) { column }
    column.stub_chain(:data, :[]).with('label') { 's.acceptance' }
    label.stub(:save)
  end

  describe '#initialize' do
    Then { expect(label.story).to eq(story) }
    And { expect(label.labels).to eq(%w[s.pending s.qa]) }
  end

  describe '#to_a' do
    Then { expect(label.to_a).to eq(%w[s.pending s.qa]) }
  end

  describe '#eq?' do
    Then  { expect(label.eq?('s.qa,s.pending')).to be_true }
    And   { expect(label.eq?('s.pending')).to be_false }
  end

  describe '#set_for_column' do
    When  { label.set_for_column(column) }
    Then  { expect(label.labels).to include('s.acceptance') }
    And   { expect(label.labels).not_to include('s.pending') }
  end

  describe '#assign_attributes' do
    describe 'when transitioning to labeled column' do
      Given { column.stub_chain(:data, :[]).with('label') { 's.labeled' } }
      When  { label.assign_attributes }
      Then  { expect(label.labels).to include('s.labeled') }
      And   { expect(label.labels).not_to include('s.pending') }
    end

    describe 'when transitioning to non-labeled column' do
      Given { column.stub_chain(:data, :[]).with('label') { nil } }
      When  { label.assign_attributes }
      Then  { expect(label.labels).to be_empty }
    end
  end
end
