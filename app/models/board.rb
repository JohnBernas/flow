class Board < ActiveRecord::Base
  has_many :swimlanes, dependent: :destroy
  has_many :columns, dependent: :destroy
  has_many :stories, through: :columns

  attr_accessor :project
  store_accessor :data, :project_id

  def synchronize
    updated_stories = project.stories.all(includedone: false).each_with_object([]) do |remote, arr|
      arr << Pivotal.create_or_update_from_remote(remote)
    end

    stories.where('stories.id NOT IN (?)', updated_stories.map(&:id)).destroy_all
  end

  def project
    @project ||= PivotalTracker::Project.find(project_id)
  end
end
