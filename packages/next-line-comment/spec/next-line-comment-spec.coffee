describe 'NextLineComment', ->
  [buffer, editor, editorElement] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = null

    waitsForPromise ->
      atom.workspace.open('sample.rb').then (o) ->
        editor = o

    waitsForPromise ->
      atom.packages.activatePackage('language-ruby')

    runs ->
      activationPromise = atom.packages.activatePackage("next-line-comment")
      editorElement = atom.views.getView(atom.workspace.getActiveTextEditor())
      atom.commands.dispatch(editorElement, 'next-line-comment:toggle')
      editor.undo()

    waitsForPromise ->
      activationPromise

    runs ->
      buffer = editor.buffer

  describe 'when there is one cursor', ->
    beforeEach ->
      editor.setCursorBufferPosition([0, 3])
      atom.commands.dispatch(editorElement, 'next-line-comment:toggle')

    it 'toggles a comment on the current line', ->
      expect(buffer.lineForRow(0)).toBe '# 3.times do |i|'
      expect(buffer.lineForRow(1)).toBe '  puts "#{i + 1}. Hello!"'
      expect(buffer.lineForRow(2)).toBe "  puts ''"
      expect(buffer.lineForRow(3)).toBe 'end'

    it 'moves the cursor on the next line saving the column number', ->
      expect(editor.getCursorBufferPosition()).toEqual([1, 3])

  describe 'when there are several cursors', ->
    beforeEach ->
      editor.setCursorBufferPosition([0, 3])
      editor.addCursorAtBufferPosition([2, 3])
      atom.commands.dispatch(editorElement, 'next-line-comment:toggle')

    it 'toggles comments on the current lines', ->
      expect(buffer.lineForRow(0)).toBe '# 3.times do |i|'
      expect(buffer.lineForRow(1)).toBe '  puts "#{i + 1}. Hello!"'
      expect(buffer.lineForRow(2)).toBe "  # puts ''"
      expect(buffer.lineForRow(3)).toBe 'end'

    it 'does not move cursors on the next lines', ->
      [cursor1, cursor2] = editor.getCursors()
      expect(cursor1.getBufferPosition()).toEqual([0, 5])
      expect(cursor2.getBufferPosition()).toEqual([2, 5])

    it 'uncomments recently commented lines with one stroke', ->
      atom.commands.dispatch(editorElement, 'next-line-comment:toggle')
      expect(buffer.lineForRow(0)).toBe '3.times do |i|'
      expect(buffer.lineForRow(1)).toBe '  puts "#{i + 1}. Hello!"'
      expect(buffer.lineForRow(2)).toBe "  puts ''"
      expect(buffer.lineForRow(3)).toBe 'end'

  describe 'when there are several lines selected', ->
    beforeEach ->
      editor.setSelectedBufferRange([[0, 5], [1, 5]])
      atom.commands.dispatch(editorElement, 'next-line-comment:toggle')

    it 'toggles comments on the current lines', ->
      expect(buffer.lineForRow(0)).toBe '# 3.times do |i|'
      expect(buffer.lineForRow(1)).toBe '#   puts "#{i + 1}. Hello!"'
      expect(buffer.lineForRow(2)).toBe "  puts ''"
      expect(buffer.lineForRow(3)).toBe 'end'

    it 'does not move the cursor', ->
      expect(editor.getCursorBufferPosition()).toEqual([1, 7])

  describe 'when a comment is trigged on the last line', ->
    it 'the cursor moves to the right for two chars in Ruby', ->
      editor.setCursorBufferPosition([4, 0])
      editor.insertText('a sentence')
      editor.setCursorBufferPosition([4, 2])
      atom.commands.dispatch(editorElement, 'next-line-comment:toggle')
      expect(buffer.lineForRow(4)).toBe '# a sentence'
      expect(editor.getCursorBufferPosition()).toEqual([4, 4])
