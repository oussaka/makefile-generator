WRAPPER_EXEC_USER ?=
GULP_BIN ?= ./node_modules/gulp/bin

##
## Gulp actions
## ------------
##

gulp: ## run gulp build
gulp:
	@$(WRAPPER_EXEC_USER) $(GULP_BIN)/bin/gulp.js build

gulp-watch: ## run gulp watch
gulp-watch:
	@$(WRAPPER_EXEC_USER) ./node_modules/gulp/bin/gulp.js gulp

.PHONY: gulp gulp-watch
