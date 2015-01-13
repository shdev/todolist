
// http://stefanimhoff.de/2014/gulp-tutorial-1-intro-setup

var destBase = 'build';

var dirs = {
  dest : {
    base : destBase,
    css : destBase + '/css',
    images : destBase + '/images',
    fonts : destBase + '/fonts',
    js : destBase + '/js',
    js_ext : destBase + '/js/external' 
  },
  src : {
    sass : 'scss',
    files : 'files',
    coffee : 'coffee',
    compass : 'config/compass.rb'
  }
}


module.exports = {
  autoprefixer: {
    browsers: [
      'last 2 versions',
      'safari 5',
      'ie 8',
      'ie 9',
      'opera 12.1',
      'ios 6',
      'android 4'
    ],
    cascade: true
  },
  browsersync: {
    development: {
      server: {
        baseDir: [dirs.dest.base]
      },
      port: 9999,
      files: [
        dirs.dest.css + '/*.css',
        dirs.dest.js + '/**/*.js',
        dirs.dest.images + '/**',
        dirs.dest.fonts + '/*'
      ]
    }
  },
  coffeelint: {
    src : dirs.src.coffee + '/*.{coffee,litcoffee}'
  },
  compass: {
    config_file: dirs.src.compass,
    css: dirs.dest.css,
    image: dirs.dest.images,
    js: dirs.dest.js,
    sass: dirs.src.sass,
    sourcemap: false,
    style: "compressed",
    time: true,
  },
  copyFiles: {
    src:  dirs.src.files + '/**/*',
    dest: dirs.dest.base
  },
  delete: {
    src: [dirs.dest.base]
  },
  dirs : dirs,
  jshint: {
    src: dirs.dest.js + '/*.js'
  },
  optimize : {
    html: {
      src: dirs.dest.base + '/**/*.html',
      dest: dirs.dest.base + '/',
      options: {
        collapseWhitespace: true
      }
    },
    images: {
      src:  dirs.dest.images + '/**/*.{jpg,jpeg,png,gif}',
      dest: dirs.dest.images + '/',
      options: {
        optimizationLevel: 3,
        progessive: true,
        interlaced: true
      }
    },
    js: {
      src:  dirs.dest.js + '/*.js',
      dest: dirs.dest.js + '/',
      options: {}
    }
  },
  sass: {
    src:  dirs.src.sass + '/**/*.{sass,scss}',
    dest: dirs.dest.css,
    options: {
      noCache: true,
      compass: true,
      bundleExec: true,
      sourcemap: false,
      sourcemapPath: '../../_assets/scss'
    },
    minifyOptions : {
      keepSpecialComments: 0
    }
  },
  watch: {
    sass: dirs.src.sass + '/**/*.{sass,scss}',
    files: dirs.src.files + '/**/*',
    coffee: dirs.src.coffee + '/**/*.{coffee,litcoffee}',
  },
};