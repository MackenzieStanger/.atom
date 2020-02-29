{CompositeDisposable} = require 'atom'

module.exports = NextLineComment =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'next-line-comment:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()

  toggle: ->
    editor = atom.workspace.getActiveTextEditor()
    position = editor.getCursorScreenPosition()

    editor.transact ->
      for selection in editor.selections
        selection.toggleLineComments()

    return if editor.hasMultipleCursors() or @isMultiSelection(editor) or @isLastLine(editor)

    editor.setCursorScreenPosition position
    editor.moveDown()

  isMultiSelection: (editor) ->
    range = editor.getSelectedScreenRange()
    range.start.row - range.end.row isnt 0

  isLastLine: (editor) ->
    editor.getLastBufferRow() is editor.getCursorBufferPosition().row
