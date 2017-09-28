# Delexe

[![Build Status](https://travis-ci.org/jonruttan/delexe.svg)](https://travis-ci.org/jonruttan/delexe)
[![Greenkeeper badge](https://badges.greenkeeper.io/jonruttan/delexe.svg)](https://greenkeeper.io/)

Read in JSON/CSON tokens from a TextMate-style lexical analyser and render the tokens with rendering modules written in a TextMate-style syntax.

Companion to the [Textlex](https://github.com/jonruttan/textlex) lexical analyser project.

Based on code converted from the [Highlights](https://github.com/atom/highlights) project.

### Installing

```sh
npm install delexe
```

### Using

Run `delexe -h` for full details about the supported options.

To convert a JSON token file to tokenized HTML run the following:

```sh
delexe tokens.json -o file.html
```

Now you have a `file.html` file that has a big `<pre>` tag with a `<div>` for
each line with `<span>` elements for each token's scope.

Then you can compile an existing Atom theme into a stylesheet with the
following:

```sh
git clone https://github.com/atom/atom-dark-syntax
cd atom-dark-syntax
npm install -g less
lessc --include-path=stylesheets index.less atom-dark-syntax.css
```

Now you have an `atom-dark-syntax.css` stylesheet that can be combined with
the `file.html` file to generate some nice looking code.

Check out the [examples](https://jonruttan.github.io/delexe/examples) to see
it in action.

Check out [atom.io](https://atom.io/packages) to find more themes.

Some popular themes:
  * [atom-dark-syntax](https://github.com/atom/atom-dark-syntax)
  * [atom-light-syntax](https://github.com/atom/atom-light-syntax)
  * [solarized-dark-syntax](https://github.com/atom/solarized-dark-syntax)
  * [solarized-light-syntax](https://github.com/atom/solarized-light-syntax)

#### Using in code

To convert a JSON token string to tokenized HTML run the following:

```js
var Delexe = require('delexe');
var renderer = new Delexe();
var fileTokens = [
  [
    {
      "value": "var",
      "scopes": [
        "source.js",
        "storage.modifier.js"
      ]
    },
    {
      "value": " hello ",
      "scopes": [
        "source.js"
      ]
    },
    {
      "value": "=",
      "scopes": [
        "source.js",
        "keyword.operator.js"
      ]
    },
    {
      "value": " ",
      "scopes": [
        "source.js"
      ]
    },
    {
      "value": "'",
      "scopes": [
        "source.js",
        "string.quoted.single.js",
        "punctuation.definition.string.begin.js"
      ]
    },
    {
      "value": "world",
      "scopes": [
        "source.js",
        "string.quoted.single.js"
      ]
    },
    {
      "value": "'",
      "scopes": [
        "source.js",
        "string.quoted.single.js",
        "punctuation.definition.string.end.js"
      ]
    },
    {
      "value": ";",
      "scopes": [
        "source.js",
        "punctuation.terminator.statement.js"
      ]
    }
  ]
];

var text = renderer.renderSync({
  fileTokens: fileTokens
});

console.log(text);


var html = renderer.renderSync({
  scopeName: 'text.html.plain',
  fileTokens: fileTokens
});

console.log(html);
```

Outputs:

```
var hello = 'world';
```

```html
<pre class="editor editor-colors">
  <div class="line">
    <span class="source js">
      <span class="storage modifier js">var</span>
      &nbsp;hello&nbsp;
      <span class="keyword operator js">=</span>
      &nbsp;
      <span class="string quoted single js">
        <span class="punctuation definition string begin js">&#39;</span>
        world
        <span class="punctuation definition string end js">&#39;</span>
      </span>
      <span class="punctuation terminator statement js">;</span>
    </span>
  </div>
</pre>
```

### Developing

* Clone this repository `git clone https://github.com/jonruttan/delexe`
* Update the submodules by running `git submodule update --init --recursive`
* Run `npm install` to install the dependencies, compile the CoffeeScript, and
  build the grammars
* Run `npm test` to run the specs

:green_heart: Pull requests are greatly appreciated and welcomed.
