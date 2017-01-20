path = require 'path'
_ = require 'underscore-plus'
fs = require 'fs-plus'
CSON = require 'season'
{RendererRegistry} = require 'last-mate'

module.exports =
class Delexe
  # Public: Create a new token renderer.
  #
  # options - An Object with the following keys:
  #   :includePath - An optional String path to a file or folder of Renderer
  #                  renderers to register.
  #   :registry    - An optional RendererRegistry instance.
  constructor: ({@includePath, @registry}={}) ->
    @registry ?= new RendererRegistry()

  loadRenderersSync: ->
    return if @registry.renderers.length > 1

    if typeof @includePath is 'string'
      if fs.isFileSync(@includePath)
        @registry.loadRendererSync(@includePath)
      else if fs.isDirectorySync(@includePath)
        for filePath in fs.listSync(@includePath, ['cson', 'json'])
          @registry.loadRendererSync(filePath)

    renderersPath = path.join(__dirname, '..', 'gen', 'renderers.json')
    for rendererPath, renderer of JSON.parse(fs.readFileSync(renderersPath))
      continue if @registry.rendererForScopeName(renderer.scopeName)?
      renderer = @registry.createRenderer(rendererPath, renderer)
      @registry.addRenderer(renderer)

  # Public: Require all the renderers from the renderers folder at the root of an
  #   npm module.
  #
  # modulePath - the String path to the module to require renderers from. If the
  #              given path is a file then the renderers folder from the parent
  #              directory will be used.
  requireRenderersSync: ({modulePath}={}) ->
    @loadRenderersSync()

    if fs.isFileSync(modulePath)
      packageDir = path.dirname(modulePath)
    else
      packageDir = modulePath

    renderersDir = path.resolve(packageDir, 'renderers')

    return unless fs.isDirectorySync(renderersDir)

    for file in fs.readdirSync(renderersDir)
      if rendererPath = CSON.resolve(path.join(renderersDir, file))
        @registry.loadRendererSync(rendererPath)

  # Public: Render the given tokens.
  #
  # options - An Object with the following keys:
  #   :fileTokens - The optional tokenized contents of the file. The file will
  #                   be read from disk if this is unspecified
  #   :filePath     - The String path to the input file.
  #   :outputPath   - The String path to the output file.
  #   :scopeName    - An optional String scope name of a renderer. The best match
  #                   renderer will be used if this is unspecified.
  #
  # Returns a String of HTML. The HTML will contains one <pre> with one <div>
  # per line and each line will contain one or more <span> elements for the
  # tokens in the line.
  renderSync: ({filePath, outputPath, fileTokens, scopeName}={}) ->
    @loadRenderersSync()

    fileTokens ?= CSON.readFileSync(filePath) if filePath
    renderer = @registry.rendererForScopeName(scopeName)
    renderer ?= @registry.selectRenderer outputPath

    # Remove trailing newline
    if fileTokens.length > 0
      lastLineTokens = fileTokens[fileTokens.length - 1]
      if lastLineTokens.length is 1 and lastLineTokens[0].value is ''
        fileTokens.pop()

    renderer.renderLines fileTokens
