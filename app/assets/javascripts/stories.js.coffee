class window.Story
  @SELECTOR: 'section.board .story[data-id]'

  constructor: (element) ->
    @el = element
    @_set_attr_readers('private')

  # Class methods
  @find_or_create: (story) -> @find(story.id) or @create(story)
  @find: (id) -> window.stories[id]
  @create: (story) ->
    node    = $('<div>').addClass('story').attr('data-id', story.id)
    fields  = $('<div>').appendTo(node).addClass('story-fields')
    key     = $('<div>').appendTo(fields).addClass('key')

    url = story.remote.url.replace('/api/v2', '').replace('.json', '')
    link    = $('<a>').appendTo(key).attr('href', url).attr('target', '_blank').text(story.remote.id)
    summary = $('<div>').appendTo(fields).addClass('summary')
    title   = $('<span>').appendTo(summary).addClass('inner').attr('title', story.remote.subject).text(story.remote.subject)

    window.stories[story.id] = new window.Story(node)

  @redraw: (stories) ->
    for _, story of window.stories
      story.remove()

    for story, index in stories
      story.priority = index
      @create(story).update_attributes(story).publish()#.highlight()

  # Instance methods
  update_attributes: (story) ->
    @title = story.remote.subject
    @id = story.id
    @pid = story.pid
    @sid = story.sid
    @remote = story.remote
    @labels = story.labels
    @priority = story.priority
    @swimlane = Swimlane.find(story.sid)
    @column = @swimlane.columns[story.column_id]

    @_story_updated('updated')
    @ # chaining

  publish: ->
    @_el_title.html(@title)
    @_el.appendTo(@swimlane.columns[@column.id].el)
    @_set_priority(@priority)
    @_story_updated('published')
    @ # chaining

  highlight: (go = true) ->
    @_el.stop(true, true).effect('highlight', { color: '#FFC200' }, 1500) if go
    @_story_updated('highlighted')

  remove: ->
    delete window.stories[@id]
    @_el.remove()
    @_story_updated('removed')

  drag_update: (ui) ->
    @swimlane = Swimlane.find ui.item.parents('.swimlane').data('id')
    @column   = @swimlane.columns[ui.item.parent().data('id')]
    @priority = ui.item.parent().find(ui.item).index()

  payload: ->
    {
      column_id: @column.id
      id: @id
      labels: @labels
      pid: @pid
      priority: @priority
      sid: @swimlane.id
      remote: @remote
    }

  # Private methods
  _story_updated: (event) -> new Event(@, event)

  _set_attr_readers: (type) ->
    switch type
      when 'private'
        @_el              = $(@el)
        @_el_title        = @_el.find('.summary .inner')

  ## Getters
  _get_column: -> window.Column.find(@_el.parents(Column.SELECTOR).data('id'))
  _get_id: -> @_el.data('id')
  _get_title: -> @_el_title.text()
  _get_description: -> @_el_description.text()
  _get_state: -> @_el.data('state')
  _get_priority: -> @_el.index()
  _get_tags: ->
    try @_el.data('tags').split(',')
    catch e
      []

  ## Setters
  _set_priority: (pos) ->
    pos = switch pos
            when "first", "middle" then 0
            when "last" then $(@column.el).children().length
            else parseInt(pos)

    if pos is 0
      $(@column.el).prepend(@el)
    else
      $(@column.el).children().eq(pos-1).after(@el)
