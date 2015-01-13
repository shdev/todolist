var gulp = require('gulp');
var config = require('../../config').watch;

/**
 * Start build task and then watch files for changes
 */
gulp.task('watch', ['build'], function() {
	gulp.watch(config.sass, ['sass', 'manifest']);
	// gulp.watch(config.sass, ['sass', 'scsslint']);
	gulp.watch(config.files, ['copyfile', 'manifest']);
	gulp.watch(config.coffee, ['coffee', 'manifest']);
});
