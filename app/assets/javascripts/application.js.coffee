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
  new window.Board('table.board')

  Story.channel.bind 'redraw', (stories) -> Story.redraw(stories)

  Story.channel.bind 'story_update', (stories) ->
    for story in _.flatten([stories], true)
      if ! story.column_id
        window.Story.find(story).remove()
      else
        window.Story
          .find_or_create(story)
          .update_attributes(story)
          .publish()
          .highlight(window.story_updated != story.id)

        delete window.story_updated


  # Setup global storage containers
  window.stories = {}
  window.columns = {}
  window.swimlanes = []


  Column.reload()
  Swimlane.reload()
  $(Story.SELECTOR).each -> new window.Story(@)

  $.getJSON "/boards/#{window.board.id}/stories", (stories) -> Story.redraw(stories)

  # Click on swimlane toggle
  $(document).on 'click', '.swimlane .twixie', ->
    Swimlane.find($(@).parents(Swimlane.SELECTOR).data('id')).close()

  # Disable columns when dragging stories
  # $(document).on 'mousedown', 'ul.stories', -> Column.disable()

  # Enable all stories after dragging
  # $(document).on 'mouseup', -> $('.stories').sortable('enable').sortable('refresh')

  $('.swimlane').each ->
    $(this).sortable
      connectWith: ".swimlane[data-id=\"#{$(this).attr('data-id')}\"]"
      items: '> li.story'
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

        # swimlanes = ui.item.parents('.stories').children('ul.swimlane')
        id = ui.item.parents('.swimlane').data('id')

        $("ul.swimlane.empty[data-id=#{id}]").fadeIn 200, ->
          $(this).sortable(window.sortableOpts)
            .sortable('option', 'connectWith', ".swimlane[data-id=\"#{$(this).attr('data-id')}\"]")
          $('.swimlane').sortable('refresh')

        # toggleEmptySwimlanes(ui)


      beforeStop: (e, ui) -> toggleEmptySwimlanes()

      receive: (e, ui) ->
        # rearangeSwimlanes(ui)
        # cid   = $(this).data('id')
        # swimlane_id   = $(this).parents('.swimlane').data('id')

        # $(ui.sender).sortable('cancel') if Swimlane.find(swimlane_id).columns[cid].is_full()

      update: (e, ui) ->
        if this is ui.item.parent()[0]
          story = Story.find ui.item.data('id')
          story.drag_update(ui)

          window.story_updated = story.id
          setTimeout('delete(window.story_updated);', 500)

          # Send story changes to other clients
          Story.channel.trigger('story_update', story.payload())

          # Notify server of updated story
          Event.dispatcher.trigger('story_update', story.payload())

  window.sortableOpts = $('.swimlane').sortable('option')

  toggleEmptySwimlanes = ->
    $('.swimlane').each ->
      $(this).fadeOut(200, -> $(this).addClass('empty')) unless $(this).find('li.story').length
        # $(this).fadeOut(200, -> $(this).remove()) unless $(this).find('li.story').length

    # else
    #   swimlane = ui.item.parents('.swimlane')
    #   $('.stories').each ->
    #     column = $(this)

    #     if ! column.find(".swimlane[data-id=#{swimlane.attr('data-id')}]").length
    #       clone = swimlane.clone()
    #       clone.find('li:not(.header)').remove().end()
    #       .hide().prependTo(column).fadeIn(200)
    #       .sortable($(swimlane).sortable('option'))

  rearangeSwimlanes = (ui) ->
    $('.column .stories').each ->
      array = []
      column = $(this)
      column.find('ul.swimlane').attr 'data-id', (i, e) -> array.push(e)

      $.each array.sort(), (i, e) ->
        column.find("ul.swimlane[data-id=#{e}]")
          .appendTo(column).sortable('refresh')
