var gulp = require('gulp'),
    nodemon = require('gulp-nodemon');

gulp.task('serve', function () {
    nodemon({script: './bin/www', ext: 'js', ignore: []})
        .on('restart', function () {
            console.log('Server has been restarted.')
        })
});