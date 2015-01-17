var gulp = require('gulp');
var manifest = require('gulp-manifest');
var config = require('../../config').manifest;
var dirs = require('../../config').dirs;


gulp.task('manifest', function(){
  gulp.src([ dirs.dest.base + '/**/*'])
    .pipe(manifest(config.options))
    .pipe(gulp.dest(dirs.dest.base));
});