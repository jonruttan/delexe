path = require 'path'
delexe = require '../src/delexe'

describe "Delexe", ->
  describe "renderSync", ->
    it "returns an HTML string", ->
      renderer = new delexe()
      html = renderer.renderSync(scopeName: 'text.html.basic', fileTokens: [[{value:'test',scopes:['text.plain.null-grammar']}]])
      expect(html).toBe '<pre class="editor editor-colors"><div class="line"><span class="text plain null-grammar">test</span></div></pre>'

    it "uses the given scope name as the grammar to tokenize with", ->
      renderer = new delexe()
      html = renderer.renderSync(scopeName: 'text.html.basic', fileTokens: [[{value:'test',scopes:['source.coffee']}]])
      expect(html).toBe '<pre class="editor editor-colors"><div class="line"><span class="source coffee">test</span></div></pre>'

    it "uses the best grammar match when no scope name is specified", ->
      renderer = new delexe()
      html = renderer.renderSync(scopeName: 'text.html.basic', fileTokens: [[{value:'test',scopes:['source.coffee']}]])
      expect(html).toBe '<pre class="editor editor-colors"><div class="line"><span class="source coffee">test</span></div></pre>'
