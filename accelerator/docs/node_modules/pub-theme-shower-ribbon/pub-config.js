// pub-theme-shower-ribbon pub-config

module.exports = {

  'pub-pkg': 'pub-theme-shower-ribbon',

  sources: './templates',

  generatorPlugins: './plugins/generator-plugin.js',

  staticPaths: [
    { path:'./node_modules/shower-core/shower.min.js', route:'/shower', inject:true },
    { path:'./node_modules/shower-ribbon/styles/screen.css', route:'/shower/ribbon/styles', inject:true },
    { path:'./css/pub-theme-shower-ribbon.css', route:'/css', inject:true },
    { path:'./node_modules/shower-ribbon/images', route:'/shower/ribbon/images' },
    { path:'./node_modules/shower-ribbon/fonts', route:'/shower/ribbon/fonts' },
    { path:'./node_modules/shower-core/License.md', route:'/shower' },
    { path:'./node_modules/shower-ribbon/License.md', route:'/shower/ribbon' }
  ],

};
