class window.Column
  @SELECTOR: '.column[data-id]'

  constructor: (element) ->
    @el = element
    @_set_attr_readers('private')
    @_set_attr_readers('public')

    # Global columns storage
    window.columns[@id] = @

  # Class methods
  @find: (id) -> window.columns[id]

  @redraw: -> column.redraw() for _, column of window.columns

  @disable: ->
    c.sortable('disable') for c in window.full_columns
    $('.stories').sortable('refresh')

  @update_full_list: ->
    window.full_columns = []
    for _, c of window.columns
      window.full_columns.push c._el if c.is_full()

  @update_quantities: ->
    $('ul.headers .column').each ->
      index = $(@).index()
      stories = 0
      $(Swimlane.SELECTOR).each ->
        column = $(@).find('.column')[index]
        stories += $(column).find('.story').size()

      $(@).find('.col-qty .qty .total').text(stories)

      if $(@).find('.col-qty .busted')
        max = parseInt($(@).find('.col-qty .busted').text(), 10)
        if stories > max
          $(@).removeClass('busted-limit')
          $(@).addClass('busted-max')
        else if stories is max
          $(@).removeClass('busted-max')
          $(@).addClass('busted-limit')
        else
          $(@).removeClass('busted-max busted-limit')

        $(Swimlane.SELECTOR).each ->
          column = $(@).find('.column')[index]
          if stories > max
            $(column).removeClass('busted-limit')
            $(column).addClass('busted-max')
          else if stories is max
            $(column).removeClass('busted-max')
            $(column).addClass('busted-limit')
          else
            $(column).removeClass('busted-max busted-limit')

  # Instance methods
  stories: ->
    stories = {}
    for _, story of window.stories
      stories[story.id] = story if story.column_id is @id and story.swimlane_id is @swimlane.id
    stories

  limit: -> parseInt @_el.data('limit')

  size: -> @stories().length

  state: ->
    return 'empty' if ! @stories().length
    return 'full' if @limit() > 0 and @size() >= @limit()
    'healthy'

  is_empty: ->    @state() is 'empty'
  is_full: ->     @state() is 'full'
  is_healthy: ->  @state() is 'healthy'

  redraw: ->
    @_el.removeClass('full healthy').addClass('empty') if @is_empty()
    @_el.removeClass('empty healthy').addClass('full') if @is_full()
    @_el.removeClass('empty full').addClass('healthy') if @is_healthy()

  disable: -> @_el.sortable('disable')

  # Private methods
  _set_attr_readers: (type) ->
    switch type
      when 'private'
        @_el              = $(@el)
      when 'public'
        @id               = @_get_id()
        # @swimlane         = @_get_lane()
        @board            = @_get_board()
        # @position         = @_get_position()

  ## Getters
  _get_id: -> @_el.data('id')
  _get_lane: ->
    window.Swimlane.find(@_el.parents(Swimlane.SELECTOR).data('id'))
  _get_board: -> window.board
  _get_position: -> $.inArray @_el, $(@swimlane.el).find(Column.SELECTOR)

  ## Setters
  _set_position: (pos) ->
    pos = switch pos
            when "first", "middle" then 0
            when "last" then $(@column).children().length
            else parseInt(pos)

    if pos is 0
      @_el_column.prepend(@el)
    else
      @_el_column.children().eq(@position-1).after(@el)
