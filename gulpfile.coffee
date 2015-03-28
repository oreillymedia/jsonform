# Requires
# ----------------------------------------------------------

gulp = require("gulp")
connect = require("gulp-connect")
sass = require("gulp-sass")
coffee = require("gulp-coffee")
_ = require("underscore")

gulp.task "build", ->
  gulp.src("./src/*.coffee")
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest(["dist", "test"]))

gulp.task "server", ["build"], ->
  connect.server
    port: 8002
    root: 'test'
    fallback: 'test/index.html'
  gulp.watch(['./src/*.coffee'], ['build'])