require 'pivotal-tracker'
raise 'No Environment variable PIVOTAL_TOKEN found' unless ENV['PIVOTAL_TOKEN']
PivotalTracker::Client.token = ENV['PIVOTAL_TOKEN']
