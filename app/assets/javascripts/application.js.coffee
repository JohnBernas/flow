#= require jquery
#= require jquery_ujs
#= require jquery.ui.all
#= require underscore
#= require turbolinks
#= require websocket_rails/main
#= require boards
#= require swimlanes
#= require columns
#= require stories
#= require events

# Enable sockets
Event.dispatcher = new WebSocketRails("#{window.location.hostname}:3001/websocket")
Story.channel = Event.dispatcher.subscribe('stories')

$ ->
  # Setup board
  new window.Board('section.board')

  Story.channel.bind 'redraw', (stories) -> Story.redraw(stories)

  Story.channel.bind 'story_update', (stories) ->
    for story in _.flatten([stories], true)
      window.Story
        .find_or_create(story)
        .update_attributes(story)
        .publish()
        .highlight(window.story_updated != story.id)

      delete window.story_updated


  # Setup global storage containers
  window.stories = {}
  window.columns = {}
  window.swimlanes = {}

  # # Make instance variables of all swimlanes on the board
  $(Swimlane.SELECTOR).each -> new window.Swimlane(@)

  # # Make instance variables of all columns on the board
  $(Column.SELECTOR).each -> new window.Column(@)

  # # Make instance variables of all columns on the board
  $(Story.SELECTOR).each -> new window.Story(@)

  $.getJSON "/boards/#{window.board.id}/stories", (stories) -> Story.redraw(stories)

  # Click on swimlane toggle
  $(document).on 'click', '.swimlane .twixie', ->
    Swimlane.find($(@).parents(Swimlane.SELECTOR).data('id')).close()

  # Disable columns when dragging stories
  $(document).on 'mousedown', 'ul.stories', -> Column.disable()

  # Enable all stories after dragging
  $(document).on 'mouseup', -> $('.stories').sortable('enable').sortable('refresh')

  $('.swimlane').each ->
    $(@).find('.column').sortable
      connectWith: $(@).find('.column')
      revert: 100
      cursor: 'move'
      forcePlaceHolderSize: true
      forceHelperSize: true
      scrollSensitivity: 40
      tolerance: 'pointer'
      placeholder: 'story-placeholder'

      start: (e, ui) ->
        ui.placeholder.height(ui.item.height())
        $('<div>').appendTo(ui.placeholder).addClass('bar')

      receive: (e, ui) ->
        cid   = $(@).data('id')
        sid   = $(@).parents('.swimlane').data('id')

        $(ui.sender).sortable('cancel') if Swimlane.find(sid).columns[cid].is_full()

      update: (e, ui) ->
        story = Story.find ui.item.data('id')
        story.drag_update(ui)

        if @ is ui.item.parent()[0]
          window.story_updated = story.id
          setTimeout('delete(window.story_updated);', 500)

          # Send story changes to other clients
          Story.channel.trigger('story_update', story.payload())

          # Notify server of updated story
          Event.dispatcher.trigger('story_update', story.payload())
