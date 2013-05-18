class window.Board
  constructor: (element) ->
    @el = element
    @id = $(@el).data('id')
    window.board = @
