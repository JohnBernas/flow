class window.Event
  @CLASSES: ['Board', 'Swimlane', 'Column', 'Story']

  constructor: (object, type) ->
    for klass in Event.CLASSES
      if object instanceof window[klass] or object[klass.toLowerCase()]?
        window["#{klass}Event"]? && new window["#{klass}Event"](object, type)

class window.EventConstructor extends Event
  constructor: (object, type) ->
    @["#{type}_observers"]? && @["#{type}_observers"](object)

class window.ColumnEvent extends EventConstructor
  published_observers: (column) ->
    Column.redraw()
    Column.update_full_list()

class window.SwimlaneEvent extends EventConstructor
  published_observers: (swimlane) ->
    Swimlane.redraw()
