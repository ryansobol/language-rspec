url = require 'url'

module.exports =
  build: (title, file, line) ->
    params = ["title=#{title}"]
    params.push "file=#{file}" if file
    params.push "line=#{line}" if line
    'rspec://?' + params.join '&'

  isRspec: (uri) ->
    uri[0..5] is 'rspec:'

  query: (uri) ->
    url.parse(uri, true).query
