path = require 'path'
fs = require 'fs-plus'
CSON = require 'season'

module.exports = (grunt) ->
  grunt.registerTask 'build-renderers', 'Build a single file with included renderers', ->
    renderers = {}
    depsDir = path.resolve(__dirname, '..', 'deps')
    for packageDir in fs.readdirSync(depsDir)
      renderersDir = path.join(depsDir, packageDir, 'renderers')
      continue unless fs.isDirectorySync(renderersDir)

      for file in fs.readdirSync(renderersDir)
        rendererPath = path.join(renderersDir, file)
        continue unless CSON.resolve(rendererPath)
        renderer = CSON.readFileSync(rendererPath)
        renderers[rendererPath] = renderer

    grunt.file.write(path.join('gen', 'renderers.json'), JSON.stringify(renderers))
    grunt.log.ok("Wrote #{Object.keys(renderers).length} renderers to gen/renderers.json")
