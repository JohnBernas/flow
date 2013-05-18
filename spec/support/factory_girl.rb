RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:all) do
    FactoryGirl.reload
  end

  # Track all factories and how they're used throughout the test suite
  config.add_setting :factory_girl_results
  config.before(:suite) do
    config.factory_girl_results = {}
    ActiveSupport::Notifications.subscribe('factory_girl.run_factory') do |name, start, finish, id, payload|
      next unless payload[:strategy] == :create

      execution_time_in_seconds = finish - start
      factory_name = payload[:name]
      strategy_name = payload[:strategy]

      # Notify about slow factories
      if execution_time_in_seconds >= 1
        $stderr.puts "Slow factory: #{factory_name} using strategy #{strategy_name}"
      end

      config.factory_girl_results[factory_name] ||= {}
      config.factory_girl_results[factory_name][strategy_name] ||= 0
      config.factory_girl_results[factory_name][strategy_name] += 1
    end
  end

  config.after(:suite) do

    print "\n\nCreate stategy usage: "
    klasses = []
    config.factory_girl_results.each do |klass,hash|
      klasses << "\033[31m#{klass.capitalize}: #{hash[:create]}\033[0m"
    end
    print klasses.join(', ')
  end
end
