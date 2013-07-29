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

    @board = Board.where("data -> 'host' = ?::text", URI(ticket.url).host).first
    @story = @board.stories.where("remote -> 'id' = ?::text", ticket.id)
      .first_or_create(
        column: matched_column(ticket),
        remote: attributes(ticket),
        swimlane_id: matched_swimlane(ticket).id)

    # update swimlane if changed in Zendesk
    if @story.swimlane != matched_swimlane(ticket)
      @story.swimlane_id = matched_swimlane(ticket).id
    end

    # update any remote details that have changed
    @story.remote = attributes(ticket)

    # set column to nil to hide story if not matching any column criteria
    @story.column = nil unless matched_column(ticket)
    @story.save
  end

private

  def matched_column(ticket)
    matches = {}

    # loop over each attribute of this story
    attributes(ticket).each do |key, value|
      next unless Story::CRITERIA.include?(key)

      columns = Column.none

      columns = @board.columns
        .where("string_to_array(columns.criteria -> '#{key}', ',') && ?",
        "{#{value}}")

      # loop over all matches columns, and add them with rankings
      columns.each do |column|
        if matches[column.id]
          matches[column.id][:ranking] += 1
        else
          matches[column.id] = { column: column, ranking: 1 }
        end
      end
    end

    # get highest ranking match, or inbox column
    column = nil

    # move through all rankings, going up the stack, searching unique
    matches.any? && matches.sort_by{ |_,v| [v[:ranking],v[:column].default,v[:column].display] }.reverse.each do |match|
      column = match.last[:column]
    end
    column
  end

  def matched_swimlane(ticket)
    matches = {}

    # loop over each attribute of this story
    attributes(ticket).each do |key, value|
      next unless Story::CRITERIA.include?(key)

      swimlanes = Swimlane.none

      # TODO: What if the story key is singular (and not an array), but
      # the swimlane key is an array?
      #
      # SOLVED? =>
      swimlanes = @board.swimlanes
        .where("string_to_array(swimlanes.criteria -> '#{key}', ',') && ?",
        "{#{value}}")

      # # for each key which is plural
      # # check if it contains a stringified array (one,two) not: (one, two)
      # if key.singularize.pluralize == key && value =~ /\w+,\w+/

      #   # find swimlane with same key and at least one value of array
      #   swimlanes = board.swimlanes.where("string_to_array(swimlanes.criteria -> '#{key}', ',') && string_to_array('#{value}', ',')")

      # # for each non-array key
      # else
      #   swimlanes = board.swimlanes
      #     .where("swimlanes.criteria -> '#{key}' = ?", value.to_s)
      # end

      # loop over all matches swimlanes, and add them with rankings
      swimlanes.each do |swimlane|
        if matches[swimlane.id]
          matches[swimlane.id][:ranking] += 1
        else
          matches[swimlane.id] = { swimlane: swimlane, ranking: 1 }
        end
      end
    end

    # get highest ranking match, or inbox swimlane
    swimlane = nil

    # move through all rankings, going up the stack, searching unique
    matches.any? && matches.sort_by{ |_,v| v[:ranking] }.each do |match|
      next if matches.flatten.count do |m|
        m.is_a?(Hash) && m[:ranking] == match.last[:ranking]
      end != 1
      swimlane = match.last[:swimlane]
    end

    swimlane || @board.swimlanes.inbox || @board.swimlanes.first
  end

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
      config.token = if Rails.env.test?
        'LffBvP0I5jJ1FzkwxHxeBnQI7uzfkdvR4CeHbtPm'
      else
        ENV['ZENDESK_TOKEN']
      end

      config.retry = true
    end
  end
end
