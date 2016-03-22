module.exports = function(generator) {

  var u = generator.util;
  var opts = generator.opts;
  var sources = opts.sources;
  var hb = generator.handlebars;

  // apply page-mutations to pages from non-package sources
  generator.on('pages-ready', function() {

    u.each(sources, function(source) {
      if (source._pkg) return;

      u.each(generator.sourcePage$[source.name], function(page) {

        // if no text below markdown heading use 'shout' class
        u.each(page._fragments, function(fragment) {
          if (fragment['background-image']) {
            fragment.class = (fragment.class || '') + ' background-image';
          }
          if (0 === u.trim(fragment._txt.replace(/^.*$/m,'')).length) {
            fragment.class = (fragment.class || '') + ' shout';
          }
        });

        // if first slide contains an image, use 'cover' class
        var first = page._fragments && page._fragments[0];
        if (first && /^\!\[/m.test(first._txt)) {
          page._fragments[0].class = (page._fragments[0].class || '') + ' cover';
        }

      });
    });
  });

  hb.registerHelper('background-image', function(frame) {
    var bgImg = this['background-image'];
    if (bgImg) {
      return '<img src="' + relPath(frame) + u.escape(bgImg) + '" full="1">';
    }
  });

  function relPath(frame) {
    return hb.renderOpts(frame).relPath || '';
  }

  // prevent single-page navigation in editor - main-layout is page-sensitive
  generator.on('update-view', function(path, query, hash, nav) {
    if (nav) { window.location = path; }
  });

  hb.registerHelper('menu', function(frame) {
    return this.menu || '=';
  });

  function lang(page) {
    return page.lang || u.slugify(page._href.slice(1)) || 'en';
  }

  function rtl(page) {
    var code = lang(page).replace(/-.*/,'');
    var rtlcodes = ['ar','arc','dv','ha','he','khw','ks','ku','ps','ur','yi'];
    return page.rtl || u.contains(rtlcodes, code);
  }

  hb.registerHelper('lang', function(frame) {
    return 'lang="' + lang(this) + '"';
  });


  hb.registerHelper('rtl', function(frame) {
    return 'dir="' + (rtl(this) ? 'rtl' : 'auto') + '"';
  });

  hb.registerHelper('body-class', function(frame) {
    return 'class="' +
      (this['body-class'] || 'list') +
      ' ' + lang(this) + '"';
  });

  function githubText(page) {
    switch (lang(page)) {
      case 'fr':    return 'Forkez-moi sur GitHub';
      case 'he':    return 'צור פיצול בGitHub';
      case 'id':    return 'Fork saya di Github';
      case 'ko':    return 'Github에서 포크하기';
      case 'pt-br': return 'Faça um fork no Github';
      case 'pt-pt': return 'Faz fork no Github';
      case 'tr':    return 'Github üstünde Fork edin';
      case 'uk':    return 'скопіювати на Github';
      default:      return 'Fork me on Github';
    }
  }

  hb.registerHelper('github', function(frame) {
    if (opts.github) {
      return u.format(
        '<p class="badge"><a href="%s">%s</a></p>',
        opts.github,
        this['github-text'] || githubText(this)
      );
    }
  });

  hb.registerHelper('photoCredit', function(frame) {
    if (this['photo-credit'] || opts.photoCredit) {
      return '<!-- ' + u.escape(this['photo-credit'] || opts.photoCredit) + ' -->';
    }
  });


}
