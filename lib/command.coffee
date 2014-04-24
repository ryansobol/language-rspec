module.exports =
  build: (filePath, lineNumber) ->
    command = [atom.config.get 'language-rspec.command']
    command.push filePath if filePath
    command.push "--line-number #{lineNumber}" if lineNumber
    command.push '--format progress'

    command = command.join ' '
    projectPath = atom.project.getRootDirectory().getPath()

    cmd: 'bash'
    args: ['-c', "cd #{projectPath} && #{command}"]
