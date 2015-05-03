path = require 'path'
fs = require 'fs-plus'
CSON = require 'season'
optimist = require 'optimist'
delexe = require './delexe'

module.exports = ->
  cli = optimist.describe('h', 'Show this message').alias('h', 'help')
                .describe('i', 'Path to file or folder of renderers to include').alias('i', 'include').string('i')
                .describe('o', 'File path to write the rendered output to').alias('o', 'output').string('o')
                .describe('s', 'Scope name of the renderer to use').alias('s', 'scope').string('s')
                .describe('v', 'Output the version').alias('v', 'version').boolean('v')
                .describe('f', 'File path to use for renderer detection when reading from stdin').alias('f', 'file-path').string('f')
  optimist.usage """
    Usage: delexe [options] [file]

    Input tokens from a TextMate-style lexical analyser in JSON/CSON format and render the output.

    If no input file is specified then the token list to render is read as JSON/CSON from standard in.

    If no output file is specified then the rendered output is written to standard out.
  """

  if cli.argv.help
    cli.showHelp()
    return

  if cli.argv.version
    {version} = require '../package.json'
    console.log(version)
    return

  [filePath] = cli.argv._

  outputPath = cli.argv.output
  outputPath = path.resolve(outputPath) if outputPath

  if filePath
    filePath = path.resolve(filePath)
    unless fs.isFileSync(filePath)
      console.error("Specified path is not a file: #{filePath}")
      process.exit(1)
      return

    html = new delexe().renderSync({filePath: outputPath, scopeName: cli.argv.scope})
    if outputPath
      fs.writeFileSync(outputPath, html)
    else
      console.log(html)
  else
    filePath = cli.argv.f or outputPath
    process.stdin.resume()
    process.stdin.setEncoding('utf8')
    fileContents = ''
    process.stdin.on 'data', (chunk) -> fileContents += chunk.toString()
    process.stdin.on 'end', ->
      fileTokens = CSON.parseObject(filePath, fileContents)
      html = new delexe().renderSync({filePath, fileTokens, scopeName: cli.argv.scope})
      if outputPath
        fs.writeFileSync(outputPath, html)
      else
        console.log(html)
