var gulp         = require('gulp');
var plumber      = require('gulp-plumber');
var browsersync  = require('browser-sync');
var gulpFilter   = require('gulp-filter');
var minifycss    = require('gulp-minify-css');
var size         = require('gulp-size');
var autoprefixer = require('gulp-autoprefixer');
var sourcemaps   = require('gulp-sourcemaps');
var config       = require('../../config');
var compass      = require('gulp-compass');

/**
 * Generate CSS from SCSS
 * Build sourcemaps
 */

// gulp.task('sass', function () {
//   return gulp.src(config.dirs.src.sass + '/**/*.scss')
//     .pipe(plumber({
//       errorHandler: function (error) {
//         console.log(error.message);
//         this.emit('end');
//     }}))
//     .pipe(compass(config.compass))
//     .pipe(gulp.dest(config.dirs.dest.css));
// });


gulp.task('sass', function() {
  var sassConfig = config.sass.options;

  sassConfig.onError = browsersync.notify;

  // Don’t write sourcemaps of sourcemaps
  var filter = gulpFilter(['*.css', '!*.map']);

  browsersync.notify('Compiling Sass');

  return gulp.src(config.sass.src)
    .pipe(plumber())
    .pipe(compass(config.compass))
    .pipe(sourcemaps.init())
    .pipe(autoprefixer(config.autoprefixer))
    .pipe(filter) // Don’t write sourcemaps of sourcemaps
    .pipe(minifycss(config.sass.minifyOptions))
    .pipe(sourcemaps.write('.', { includeContent: false }))
    .pipe(filter.restore()) // Restore original files
    .pipe(gulp.dest(config.sass.dest))
    .pipe(size());
});