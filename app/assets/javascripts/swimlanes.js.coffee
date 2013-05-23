class window.Swimlane
  @SELECTOR: 'section.board .swimlane[data-id]'

  constructor: (element) ->
    @el = element
    @_set_attr_readers('private')
    @_set_attr_readers('public')

    # Global swimlanes storage
    window.swimlanes[@id] = @

  # Class methods
  @find: (id) -> window.swimlanes[id]

  @redraw: -> swimlane.redraw() for _, swimlane of window.swimlanes

  # Instance variables
  parent: @board

  stories: ->
    stories = []
    for column in @columns
      stories.push column.stories
    _.flatten(stories)

  close: -> @_el.toggleClass('closed')

  redraw: ->
    @update_story_counter()

    if ! @stories().length
      @_el.addClass('empty')
    else
      @_el.removeClass('empty')

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
        @columns          = @_set_columns()

  ## Getters
  _get_id: -> @_el.data('id')
  _get_board: -> window.board
  _get_position: -> $.inArray @_el, $('body').find(Swimlane.SELECTOR)
  _set_columns: ->
    columns = {}
    for selector in @_el.find(Column.SELECTOR)
      column = new window.Column(selector)
      column.swimlane = @
      columns[column.id] = column
    columns
