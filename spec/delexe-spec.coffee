path = require 'path'
Delexe = require '../src/delexe'

describe "Delexe", ->
  describe "when an includePath is specified", ->
    it "includes the renderers when the path is a file", ->
      textlex = new Delexe(includePath: path.join(__dirname, 'fixtures', 'includes'))
      string = textlex.renderSync(scopeName: 'include1', fileTokens: [[value: 'test', scopes: [ 'text.plain.null-grammar' ]]])
      expect(string).toEqual '[body: [line: [scopes: text.plain.null-grammar [value: test]]]]'

    it "includes the renderers when the path is a directory", ->
      textlex = new Delexe(includePath: path.join(__dirname, 'fixtures', 'includes', 'include1.cson'))
      string = textlex.renderSync(scopeName: 'include1', fileTokens: [[value: 'test', scopes: [ 'text.plain.null-grammar' ]]])
      expect(string).toEqual '[body: [line: [scopes: text.plain.null-grammar [value: test]]]]'

    describe "overrides built-in renderers", ->
      it "overrides by scopeName", ->
        textlex = new Delexe(includePath: path.join(__dirname, 'fixtures', 'includes'))
        string = textlex.renderSync(scopeName: 'text.plain', fileTokens: [[value: 'test', scopes: [ 'text.plain.null-grammar' ]]])
        expect(string).toEqual '[body: [line: [scopes: text.plain.null-grammar [value: test]]]]'

      it "overrides by outputPath", ->
        textlex = new Delexe(includePath: path.join(__dirname, 'fixtures', 'includes'))
        string = textlex.renderSync(outputPath: 'txt', fileTokens: [[value: 'test', scopes: [ 'text.plain.null-grammar' ]]])
        expect(string).toEqual '[body: [line: [scopes: text.plain.null-grammar [value: test]]]]'

  describe "renderSync", ->
    it "returns an HTML string", ->
      renderer = new Delexe()
      html = renderer.renderSync(scopeName: 'text.html.basic', fileTokens: [[{value:'test',scopes:['text.plain.null-grammar']}]])
      expect(html).toBe '<pre class="editor editor-colors"><div class="line"><span class="text plain null-grammar">test</span></div></pre>'

    it "uses the given scope name as the renderer to tokenize with", ->
      renderer = new Delexe()
      html = renderer.renderSync(scopeName: 'text.html.basic', fileTokens: [[{value:'test',scopes:['source.coffee']}]])
      expect(html).toBe '<pre class="editor editor-colors"><div class="line"><span class="source coffee">test</span></div></pre>'

    it "uses the best renderer match when no scope name is specified", ->
      renderer = new Delexe()
      html = renderer.renderSync(scopeName: 'text.html.basic', fileTokens: [[{value:'test',scopes:['source.coffee']}]])
      expect(html).toBe '<pre class="editor editor-colors"><div class="line"><span class="source coffee">test</span></div></pre>'

  describe "requireRenderersSync", ->
    it "loads the renderers from a file-based npm module path", ->
      textlex = new Delexe()
      textlex.requireRenderersSync(modulePath: require.resolve('renderer-html/package.json'))
      expect(textlex.registry.rendererForScopeName('text.html.basic').path).toBe path.resolve(__dirname, '..', 'node_modules', 'renderer-html', 'renderers', 'html.cson')

    it "loads the renderers from a folder-based npm module path", ->
      textlex = new Delexe()
      textlex.requireRenderersSync(modulePath: path.resolve(__dirname, '..', 'node_modules', 'renderer-html'))
      expect(textlex.registry.rendererForScopeName('text.html.basic').path).toBe path.resolve(__dirname, '..', 'node_modules', 'renderer-html', 'renderers', 'html.cson')

    it "loads default renderers prior to loading grammar from module", ->
      textlex = new Delexe()
      textlex.requireRenderersSync(modulePath: require.resolve('renderer-html/package.json'))
      html = textlex.renderSync(scopeName: 'text.html.basic', fileTokens: [[value: 'test', scopes: [ 'text.plain.null-grammar' ]]])
      expect(html).toBe '<pre class="editor editor-colors"><div class="line"><span class="text plain null-grammar">test</span></div></pre>'
