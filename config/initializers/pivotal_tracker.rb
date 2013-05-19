require 'pivotal-tracker'

token = Rails.env.test? ? '' : ENV['PIVOTAL_TOKEN']
raise 'No Environment variable PIVOTAL_TOKEN found' unless token
PivotalTracker::Client.token = token
