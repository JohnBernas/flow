class window.Story
  @SELECTOR: 'li.story[data-id]'

  constructor: (element) ->
    @el = element
    @_set_attr_readers('private')

  # Class methods
  @find_or_create: (story) -> @find(story.id) or @create(story)
  @find: (id) -> window.stories[id]
  @create: (story) ->
    node    = $('<li>').addClass('story').attr('data-id', story.id)
    fields  = $('<div>').appendTo(node).addClass('story-fields')
    url = story.remote.url.replace('/api/v2', '').replace('.json', '')
    summary = $('<div>').appendTo(fields).addClass('summary')

    link_title = $('<a>').attr('href', url).attr('target', '_blank').text("##{story.remote.id}: #{story.remote.subject}")

    $('<span>').addClass('inner').append(link_title).appendTo(summary)

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
    @remote_id = story.remote_id
    @swimlane_id = story.swimlane_id
    @remote = story.remote
    @labels = story.labels
    @priority = story.priority
    @column = Column.find(story.column_id)
    @swimlane = Swimlane.find_or_create(@column, story.swimlane_id)
    # @column.find_or_create_swimlane(story.swimlane_id)

    @_story_updated('updated')
    this # chaining

  publish: ->
    @_el.appendTo(@column.swimlanes[@swimlane.id].el)
    @_set_priority(@priority)
    @_story_updated('published')
    this # chaining

  highlight: (go = true) ->
    @_el.stop(true, true).effect('highlight', { color: '#FFC200' }, 1500) if go
    @_story_updated('highlighted')

  remove: ->
    delete window.stories[@id]
    @_el.remove()
    @_story_updated('removed')

  drag_update: (ui) ->
    Column.reload()
    Swimlane.reload()

    @swimlane = Swimlane.find ui.item.parents('.swimlane').data('id')
    @column = Column.find(ui.item.parents('.column').data('id'))
    @priority = ui.item.parent().find(ui.item).index() - 1

  payload: ->
    {
      column_id: @column.id
      id: @id
      labels: @labels
      remote_id: @remote_id
      priority: @priority
      swimlane_id: @swimlane.id
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
            when "last" then @swimlane.stories.length
            else parseInt(pos)

    if pos is 0
      $(@swimlane.el).find('li.header').after(@el)
    else
      $(@swimlane.el).children('li.story').eq(pos-1).after(@el)
