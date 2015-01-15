var gulp = require('gulp');
var config = require('../../config').watch;

/**
 * Start browsersync task and then watch files for changes
 */
gulp.task('watch', ['browsersync'], function() {
	gulp.watch(config.sass, ['sass']);
	// gulp.watch(config.sass, ['sass', 'scsslint']);
	gulp.watch(config.files, ['copyfile']);
	gulp.watch(config.bower, ['copy:bower']);
	gulp.watch(config.coffee, ['coffee']);
});
