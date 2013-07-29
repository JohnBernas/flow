class window.Swimlane
  @SELECTOR: 'ul.swimlane[data-id]'

  constructor: (element) ->
    @el = element
    @_set_attr_readers('private')
    @_set_attr_readers('public')

    # Global swimlanes storage
    window.swimlanes.push(this)

  # Class methods
  @reload: ->
    delete window.swimlanes
    window.swimlanes = []
    $(Swimlane.SELECTOR).each -> new window.Swimlane(this)

  @find_or_create: (column, id) -> column.swimlanes[id] or @create(column, id)

  @find: (id) ->
    _.find window.swimlanes, (swimlane) ->
      swimlane.id is id # and $(swimlane.el).

  @redraw: -> swimlane.redraw() for _, swimlane of window.swimlanes

  @create: (column, id) ->
    $.getJSON "/boards/#{window.board.id}/swimlanes/#{id}", (swimlane) ->
      header = $('<li />', { class: 'header', text: swimlane.title })
      element = $('<ul />', { class: 'swimlane' }).attr('data-id', id).append(header)

      element.hide().prependTo($(column.el).find('.stories'))
        .fadeIn(200).sortable(window.sortableOpts)

      new Swimlane(element)

      console.log window.swimlanes



  # Instance variables
  parent: @board

  stories: ->
    stories = {}
    for _, story of window.stories
      stories[story.id] = story if story.swimlane_id is @id and story.column.id is @column.id
    stories

  close: -> @_el.toggleClass('closed')

  redraw: ->
    @update_story_counter()

    if _.size(@stories()) is 0
      @_el.addClass('empty').fadeOut(200)
    else
      @_el.removeClass('empty').fadeIn(200)

  update_story_counter: ->
    counter = @_el.find('.swimlane-header .info')
    total = @_el.find('.story').size()

    if total == 1
      counter.text("#{total} issue")
    else
      counter.text("#{total} issues")

  # Private methods
  _set_attr_readers: (type) ->
    switch type
      when 'private'
        @_el              = $(@el)
      when 'public'
        @id               = @_get_id()
        @board            = @_get_board()
        @position         = @_get_position()
        @column           = @_set_column()

  ## Getters
  _get_id: -> @_el.data('id')
  _get_board: -> window.board
  _get_position: -> $.inArray @_el, $('body').find(Swimlane.SELECTOR)
  _set_column: -> Column.find(@_el.parents(Column.SELECTOR).data('id'))
