#!/usr/bin/env ruby
require File.expand_path('../../config/environment', __FILE__)
require 'websocket-rails'

options = WebsocketRails.config.thin_defaults.merge(daemonize: false)
Thin::Controllers::Controller.new(options).start

puts "Websocket Rails Standalone Server listening on port #{options[:port]}"
