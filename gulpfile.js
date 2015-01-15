var gulp = require('gulp');
var coffee = require('gulp-coffee');
var spawn = require('child_process').spawn;
var sourcemaps = require('gulp-sourcemaps');
var mocha = require('gulp-mocha');
require('coffee-script/register')
var istanbul = require('gulp-coffee-istanbul');

var jsFiles = [];
var coffeeFiles = ['*.coffee'];
var specFiles = ['test/*.coffee'];

gulp.task('coverage', function() {
  gulp.src(jsFiles.concat(coffeeFiles))
      .pipe(istanbul({
                includeUntested: true
            }))
      .pipe(istanbul.hookRequire())
      .on('finish', function() {
          gulp.src(specFiles)
            .pipe(mocha({
              reporter: 'spec'
            }))
            .pipe(istanbul.writeReports({
                dir: '.',
                reporters: ['cobertura']
            }));
        });
});

/**
 * $ gulp server
 * description: launch the server. If there's a server already running, kill it.
 */
gulp.task("coffee", function() {
    gulp.src("*.coffee")
        .pipe(sourcemaps.init())
        .pipe(coffee({bare: true}))
        .pipe(sourcemaps.write("."))
        .pipe(gulp.dest("./lib"))
});

gulp.task("collect-proto", function() {
    gulp.src("../proto/*.desc")
        .pipe(gulp.dest("./lib/proto"))
});

gulp.task('watch', ['coffee', 'collect-proto'], function()
{
    gulp.watch(['./*.coffee'], ['coffee', 'test']);
    gulp.watch(['test/*.coffee'], ['test']);
});

gulp.task('test', ['coffee'], function ()
{
    return gulp.src('test/*.coffee', {read: false})
            .pipe(mocha({reporter: 'min'}));
})

gulp.task('build', ['coffee', 'collect-proto']);

gulp.task("default", ["watch"]);
