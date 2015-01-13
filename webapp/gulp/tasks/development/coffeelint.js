var gulp = require('gulp');
var coffeelint = require('gulp-coffeelint');
var config  = require('../../config').coffeelint;

gulp.task('coffeelint', function () {
    gulp.src(config.src)
        .pipe(coffeelint())
        .pipe(coffeelint.reporter())
});