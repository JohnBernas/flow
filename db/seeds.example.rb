# Board
#
# Specify the KanBan board details. You need to give your board a title,
# and the Zebdesk host.
#
board = Board.create(title: 'My Zendesk board', data: { zendesk_account: ENV['ZENDESK_HOST']})

# Swimlanes
#
# You can create as many Swimlanes as you want. If you don't want any
# seperate swimlanes, simply stick to a single siwmlane with `default` set
# to true.
#
# You can link Zendesk tickets to specific lanes by matching labels. If
# you give the swimlane a comma seperated list of labels, any story with
# at least one matching label will be linked to that swimlane. If a story
# matches multiple swimlanes, the one with a higher `horizontal` rank (and
# thus a lower integer) will be given precedence.
#
# [title] swimlane name shown above each swimlane on the page
#
# [horizontal] the horizontal position of the swimlane, 1 starting at the
# top
#
# [data][limit] soft-limit of stories in a lane. The swimlane will be
# styled appropriately if this number is superseded
#
# [data][labels] ticket labels that should be linked to this swimlane
#
# [data][default] if set to true, stories without any swimlane labels will
# be assigned to this swimlane
#
board.swimlanes.create(title: 'Criticals', horizontal: 1, data: { limit: 1, labels: 'critical' })
board.swimlanes.create(title: 'Everything else', horizontal: 2, data: { default: true })

# Columns
#
# Create as many KanBan columns as you want.
#
# [title] column name shown above the column contents
#
# [display] position of column, 1 being the left most column
#
# [data][default] if set to true, new Zendesk tickets end up here. Also,
# if you remove a column from your workflow, existing stories in that
# column will be assigned to this one
#
# [data][limit] soft-limit of maximum stories active in a column. The
# column will be styled appropriately if this number is superseded
#
board.columns.create(title: 'To Do', display: 1, data: { default: true })
board.columns.create(title: 'On Hold', display: 2)
board.columns.create(title: 'In Progress', display: 3)
board.columns.create(title: 'Deployment', display: 4)
board.columns.create(title: 'Done', display: 5)
