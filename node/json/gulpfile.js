const gulp = require('gulp');
const plumber = require('gulp-plumber');
const babel = require('gulp-babel');
const browserSync = require('browser-sync');
const sass = require('gulp-sass');

// HTML
var srcHTML = '/Users/tommix/Dropbox/MEDIASET/DEVELOPMENT/TAXONOMY/web/'

// REACT
var srcJSX = 'src/*.jsx'
var destJS = '/Users/tommix/Dropbox/MEDIASET/DEVELOPMENT/TAXONOMY/web/assets/js/'

// SASS
var srcSASS = 'src/*.scss'
var destCSS = '/Users/tommix/Dropbox/MEDIASET/DEVELOPMENT/TAXONOMY/web/assets/css/'

gulp.task('default', () => {

});

gulp.task('buildJSX', () => {
	return gulp.src(srcJSX)
      .pipe(plumber())
		.pipe(babel({
			presets: ['es2015'],
			"plugins": ["transform-react-jsx"]
		}))
		.pipe(gulp.dest(destJS));
});



gulp.task('buildSASS', function () {
  return gulp.src(srcSASS)
   .pipe(plumber())
   .pipe(sass().on('error', sass.logError))
   .pipe(gulp.dest(destCSS));
});

//.on('error', sass.logError)

gulp.task('browser-sync', function () {
	gulp.watch(srcJSX, ['buildJSX']);
   gulp.watch(srcSASS, ['buildSASS']);

   var files = [
      srcHTML,
      srcJSX,
      srcSASS
   ];

   browserSync.init(files, {
   	proxy: {
    	target: "localhost:8099"
	}
      /*
      server: {
         baseDir: './Users/tommix/Dropbox/MEDIASET/DEVELOPMENT/TAXONOMY/web/'
      }
      */
   });
});