{$, ScrollView} = require 'atom'
command = require './command'
{spawn} = require 'child_process'

module.exports = class RunnerView extends ScrollView
  @content: (title) ->
    @div class: 'language-rspec native-key-bindings', tabindex: -1, =>
      @h1 =>
        @span class: 'text-highlight inline-block', title
        @span outlet: 'loading', class: 'loading loading-spinner-small inline-block'
      @pre outlet: 'output'

  initialize: (@title, filePath, lineNumber) ->
    super

    @output.on 'click', @onClick

    {cmd, args} = command.build filePath, lineNumber

    @child = spawn cmd, args
    @child.stdout.on 'data', @onData
    @child.stderr.on 'data', @onData
    @child.on 'exit', => @loading.hide()

  getTitle: ->
    @title

  onData: (data) =>
    data = data.toString()

    data = data.replace /([^\s]*):([0-9]+)/g, (match, file, line) ->
      file = "#{atom.project.getPath()}#{file[1..]}" if file[0..1] is './'
      "<a class='highlight' data-file='#{file}' data-line='#{line}'>#{match}</a>"

    # TODO: check out https://github.com/guileen/terminal-status/blob/master/lib/command-output-view.coffee

    data = data.replace /^(\.+\n*)$/m,
      "<span class='text-success'>$1</span>"

    data = data.replace /^(F+\n*)$/m,
      "<span class='text-error'>$1</span>"

    data = data.replace /(Failures:)/g,
      "<span class='text-error'>$1</span>"

    data = data.replace /(\d+\).+)/g,
      "<span class='text-highlight'>$1</span>"

    data = data.replace /(Failure\/Error:.+)/g,
      "<span class='text-warning'>$1</span>"

    data = data.replace /(expected: )(.+)/g,
      "$1<span class='highlight-success'>$2</span>"

    data = data.replace /(got: )(.+)/g,
      "$1<span class='highlight-error'>$2</span>"

    data = data.replace /(expected )(.+)( to include )(.+)/g,
      "$1<span class='highlight-success'>$2</span>$3<span class='highlight-error'>$4</span>"

    data = data.replace /(Finished in .+)/g,
      "<span class='text-info'>$1</span>"

    data = data.replace /(\d+ examples?)/g,
      "<span class='text-success'>$1</span>"

    data = data.replace /([1-9][0-9]* failures?)/g,
      "<span class='text-error'>$1</span>"

    data = data.replace /(Failed examples:)/g,
      "<span class='text-error'>$1</span>"

    @output.append data

  onClick: (event) =>
    if event.target.tagName is 'A'
      {line, file} = $(event.target).data()
      opts = { searchAllPanes: true, initialLine: line }

      atom.workspace.open(file, opts).done (editor) ->
        editor.setCursorBufferPosition [line - 1, 0]

  destroy: ->
    @child.kill()
    @output.off()
    @detach()
