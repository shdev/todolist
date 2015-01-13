var gulp = require('gulp');
var manifest = require('gulp-manifest');
var config = require('../../config').manifest;


gulp.task('manifest', function(){
  gulp.src(['build/*'])
    .pipe(manifest(config.options))
    .pipe(gulp.dest('build'));
});