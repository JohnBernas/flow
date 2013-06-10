require 'pivotal-tracker'

token = ENV['CI'] ? 'vhTkprGx7CtvotWhwy9NzoWAmpzQisjA' : ENV['PIVOTAL_TOKEN']
raise 'No Environment variable PIVOTAL_TOKEN found' unless token
PivotalTracker::Client.token = token
PivotalTracker::Client.use_ssl = ENV['PIVOTAL_SSL'] == 'true' ? true : false
