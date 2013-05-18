# Board
#
# Specify the KanBan board details. You need to give your board a title, and the
# Project ID of your Pivotal Tracker project.
#
board = Board.create(title: 'My Pivotal Project', data: { project_id: 123456 })

# Swimlanes
#
# You can create as many Swimlanes as you want. If you don't want any seperate
# swimlanes, simply stick to a single siwmlane with `default` set to true.
#
# You can link Pivotal Tracker stories to specific lanes by matching labels. If
# you give the swimlane a comma seperated list of labels, any story with at
# least one matching label will be linked to that swimlane. If a story matches
# multiple swimlanes, the one with a higher `horizontal` rank (and thus a lower
# integer) will be given precedence.
#
# [title] swimlane name shown above each swimlane on the page
#
# [horizontal] the horizontal position of the swimlane, 1 starting at the top
#
# [data][limit] soft-limit of stories in a lane. The column will be styled
# appropriately if this number is superseded
#
# [data][labels] story labels that should be linked to this swimlane
#
# [data][default] if set to true, stories without any column labels will be
# assigned to this swimlane
#
board.swimlanes.create(title: 'Criticals', horizontal: 1, data: { limit: 1, labels: 'critical' })
board.swimlanes.create(title: 'Everything else', horizontal: 2, data: { default: true })

# Columns
#
# Create as many KanBan columns as you want. Link them with your Pivotal Tracker
# backend through states and labels.
#
# [title] column name shown above the column contents
#
# [display] position of column, 1 being the left most column
#
# [data][default] if set to true, stories not matching any other columns will
# end up here
#
# [data][state] story state linked to this column. Can be one of accepted,
# rejected, delivered, finished, started, unstarted, unscheduled
#
# [data][label] additional story label linked to this column. This allows you to
# have multiple columns linked to the same story state, with different labels
#
# [data][limit] soft-limit of maximum stories active in a column. The column
# will be styled appropriately if this number is superseded
#
board.columns.create(title: 'To Do', display: 1, data: { default: true, state: 'unstarted' })
board.columns.create(title: 'On Hold', display: 2, data: { state: 'started', label: 's.hold' })
board.columns.create(title: 'In Progress', display: 3, data: { limit: 3, state: 'started' })
board.columns.create(title: 'Deployment', display: 4, data: { limit: 6, state: 'delivered', label: 's.deploy' })
board.columns.create(title: 'Done', display: 5, data: { state: 'accepted' })
