# pub-theme-shower-ribbon
The [shower](https://github.com/shower/shower) theme for
[pub-server](https://github.com/jldec/pub-server) makes it easy to create
HTML presentations using markdown.

Edit the markdown in any text editor and use the watch feature of pub-server to auto-update a browser preview the file is saved.

When you are ready to publish, run `pub -O` to generate a set of html output and other static files.

The screenshot below shows the built-in pub-server editor (which still has a few quirks).
![](images/shower-screen.png)

### tl;dr
The quickest way to start writing your own presentations using this theme is to clone the [pub-sample-deck](https://github.com/jldec/pub-server) repo from github.

This will also install pub-server in the same directory.

```sh
git clone https://github.com/jldec/pub-sample-deck.git
cd pub-sample-deck
npm install
```


#### If you have installed pub-server globally first

```sh
npm install -g pub-server
```
Create your `presentation.md` in a new directory, then:

```sh
npm install pub-theme-shower-ribbon
pub -m -t pub-theme-shower-ribbon
```

- `-m`: interprets markdown headings as fragments
- `-t shower-ribbon` loads pub-theme-shower-ribbon if you have npm installed it.


Now open your browser on http://localhost:3001/


### markdown
- a sample presentation is included in the [example](example) folder.
- The heading at the very top the file becomes the name of the presentation
- The second heading is interpreted as a cover slide if it is followed by `![](image)`
- A slide with no text (slide 2 below) will be rendered with *shout* style (large centered text)


```markdown
# Example Presentation
Byline

## Title
![](/images/ice.jpg)
Use the nav menu to switch between presentations

## Slide 1: quote

> The overwhelming majority of theories are rejected
because they contain bad explanations, not because they
fail experimental tests.

david deutsch

## Slide 2: No text

## Slide 3: Lists

1. with with with with with with with
  - words words
  - words words
  - words words
  - words words
- nice nice nice nice nice nice

## Slide 4: Table

| col1   | col2   |     col3 header |
| ------ | ------ | --------------: |
| abc    | def    |   right aligned |
| abc    | def    |   right aligned |
| abc    | def    |   right aligned |
```


### sample `pub-config.js` configuration

Instead of command line parameters, you can use pub-config.js to configure
the theme, and say a source of images e.g. for the cover

By providing a value for `injectCss` you can inject an additional stylesheet.

```js
var opts = module.exports = {

  pkgs: ['pub-theme-shower-ribbon', 'pub-pkg-seo'],

  sources: [
    {
      path:'./markdown',
      glob:'**/*.md',
      fragmentDelim:'md-headings', // pub -m, required for this theme
      writable:true
    }
  ],

  staticPaths: [ './static' ],

  // link for github badge
  github: 'https://github.com/jldec/pub-theme-shower-ribbon',

  // path to extra stylesheet
  injectCss: '/css/extra.css',

  // don't forget photo credit
  photoCredit: 'Cover Photo by Jurgen Leschner, github.com/jldec',

  // copyright comment
  copyright: 'Copyright © 2015 Hard Working Person',

  // ask search engines not to crawl this site (depends on pub-pkg-seo)
  noRobots:true
}
```


### credits
- [Vadim Makeev](https://github.com/pepelsbey):
  [Shower HTML presentation engine ](https://github.com/shower/shower)
