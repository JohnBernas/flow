class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || connection_handler.retrieve_connection(self)
  end
end

RSpec.configure do |config|
  config.before(:all) do
    ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
  end
end
