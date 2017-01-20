'use strict'

path = require 'path'
fs = require 'fs-plus'
CSON = require 'season'
Delexe = require './delexe'

cli = require 'yargs'
  .usage '''
    Usage: delexe [options] [file...]

    Input tokens from a TextMate-style lexical analyser in JSON/CSON format and render the output.

    If no input files are specified then the token list to render is read as JSON/CSON from standard in.

    If no output file is specified then the rendered output is written to standard out.
  '''
  .option 'include',
    alias: 'i'
    describe: 'Path to file or folder of renderers to include'
    type: 'string'
  .option 'output',
    alias: 'o'
    describe: 'File path to write the rendered output to'
    type: 'string'
  .option 'scope',
    alias: 's'
    describe: 'Scope name of the renderer to use'
    type: 'string'
  .option 'file-path',
    alias: 'f'
    describe: 'File path to use for renderer detection when writing to stdout'
    type: 'string'
  .help()
  .alias 'h', 'help'
  .version ->
    {version} = require '../package.json'
    return version
  .alias 'v', 'version'

module.exports = ->
  outputPath = cli.argv.output
  outputPath = path.resolve(outputPath) if outputPath

  delexe = new Delexe includePath: cli.argv.include

  output = (outputPath, string) ->
    if outputPath
      fs.writeFileSync outputPath, string
    else
      console.log string

  if cli.argv._.length
    console.log outputPath
    for filePath in cli.argv._
      filePath = path.resolve filePath
      unless fs.isFileSync filePath
        console.error "Specified path is not a file: #{filePath}"
        process.exit 1
        return

      string = delexe.renderSync {filePath, outputPath, scopeName: cli.argv.scope}
      output outputPath, string
  else
    process.stdin.resume()
    process.stdin.setEncoding 'utf8'
    fileContents = ''
    process.stdin.on 'data', (chunk) -> fileContents += chunk.toString()
    process.stdin.on 'end', ->
      fileTokens = CSON.parse fileContents
      string = delexe.renderSync {
        filePath
        outputPath: cli.argv.f or outputPath
        fileTokens
        scopeName: cli.argv.scope
      }
      output outputPath, string
