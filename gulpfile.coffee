gulp = require("gulp")
connect = require("gulp-connect")
sass = require("gulp-sass")
coffee = require("gulp-coffee")
include = require("gulp-include")
gulpMerge = require('gulp-merge')
jstConcat = require('gulp-jst-concat')
concat = require('gulp-concat')
_ = require("underscore")

gulp.task "build", ->

  # JS and JST
  gulpMerge(
    gulp.src("src/jsonform.coffee")
      .pipe(include())
      .pipe(coffee({bare: true}))
  ,
    gulp.src('src/fields/*.jst')
      .pipe(jstConcat('jst.js', {
        renameKeys: ['^.*src/(.*).jst$', '$1']
      }))
  ).pipe(concat('jsonform.js'))
  .pipe(gulp.dest("dist"))
  .pipe(gulp.dest("test"))

  # CSS
  gulp.src("src/jsonform.scss")
    .pipe(sass())
    .pipe(gulp.dest("dist"))
    .pipe(gulp.dest("test"))


gulp.task "server", ["build"], ->
  connect.server
    port: 8002
    root: 'test'
    fallback: 'test/index.html'
  gulp.watch(['src/**/*.coffee', 'src/**/*.jst', 'src/**/*.scss'], ['build'])