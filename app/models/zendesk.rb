require 'zendesk_api'

class Zendesk
  KEYS = %w[url id created_at updated_at type subject description priority
    status recipient requester_id submitter_id assignee_id organization_id
    group_id collaborator_ids problem_id has_incidents due_at tags
    satisfaction_rating]

  attr_reader :story

  def self.client
    connect_to_zendesk
  end

  def initialize(ticket)
    unless ticket.is_a?(ZendeskAPI::Ticket)
      ticket = Zendesk.client.tickets.find(id: ticket)
    end

    board = Board.where("data -> 'host' = ?::text", URI(ticket.url).host).first
    @story = board.stories.where("remote -> 'id' = ?::text", ticket.id)
      .first_or_create(column: board.columns.inbox, remote: attributes(ticket))
  end

private

  def attributes(ticket)
    ticket.attributes.each_with_object({}) do |(key, value), hash|
      next unless KEYS.include?(key)

      value = value.join(',') if value.is_a?(Array)
      hash[key] = value
    end
  end

  def self.connect_to_zendesk
    ZendeskAPI::Client.new do |config|
      raise 'Missing environment variable: ZENDESK_TOKEN' unless ENV['ZENDESK_TOKEN']
      raise 'Missing environment variable: ZENDESK_USER' unless ENV['ZENDESK_USER']
      raise 'Missing environment variable: ZENDESK_HOST' unless ENV['ZENDESK_HOST']

      config.url = "https://#{ENV['ZENDESK_HOST']}/api/v2"
      config.username = ENV['ZENDESK_USER']
      config.token = ENV['ZENDESK_TOKEN']

      config.retry = true
    end
  end
end
