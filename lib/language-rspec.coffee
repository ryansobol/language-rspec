{basename} = require 'path'
url = require './url'
View = require './view'

module.exports =
  activate: ({@prevFile, @prevLine}) ->
    @views = []

    atom.config.setDefaults 'language-rspec', command: 'bundle exec rspec'

    atom.workspace.registerOpener @opener

    atom.workspaceView.command 'rspec:run-project-specs', @runProjectSpecs.bind @
    atom.workspaceView.command 'rspec:run-file-specs', @runFileSpecs.bind @
    atom.workspaceView.command 'rspec:run-single-spec', @runSingleSpec.bind @
    atom.workspaceView.command 'rspec:run-previous-specs', @runPreviousSpecs.bind @

    atom.workspaceView.eachEditorView (editorView) =>
      editor = editorView.getEditor()
      return unless @_isRspecFile(editor.getPath())
      rspecGrammar = atom.syntax.grammarForScopeName 'source.ruby.rspec'
      return unless rspecGrammar?
      editor.setGrammar rspecGrammar

  deactivate: ->
    view.destroy() for view in @views

  serialize: ->
    prevFile: @prevFile
    prevLine: @prevLine

  opener: (uri) ->
    return unless url.isRspec uri
    {title, file, line} = url.query uri
    new View title, file, line

  runProjectSpecs: ->
    @run 'Run Project Specs'

  runFileSpecs: ->
    editor = atom.workspace.getActiveEditor()
    return unless editor?

    file = editor.getPath()
    return unless @_isRspecFile(file)

    @run 'Run File Specs', file

  runSingleSpec: ->
    editor = atom.workspace.getActiveEditor()
    return unless editor?

    file = editor.getPath()
    return unless @_isRspecFile(file)

    @run 'Run Single Spec', file, editor.getCursor().getBufferRow() + 1

  runPreviousSpecs: ->
    @run 'Run Previous Specs', @prevFile, @prevLine

  run: (title, file, line) ->
    @prevFile = file
    @prevLine = line
    uri = url.build title, file, line
    atom.workspace.open(uri).done (view) => @views.push view

  _isRspecFile: (filename) ->
    rspec_filetype = 'spec.rb'
    basename(filename).slice(-rspec_filetype.length) == rspec_filetype
