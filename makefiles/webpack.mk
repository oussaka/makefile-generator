WEBPACK_ENCORE_BIN ?= ./node_modules/.bin/encore

##
## Webpack actions
## ---------------
##

webpack-build: ## build assets
webpack-build:
	@$(WRAPPER_EXEC_USER) $(WEBPACK_ENCORE_BIN) production

webpack-build-dev: ## build dev assets
webpack-build-dev:
	@$(WRAPPER_EXEC_USER) $(WEBPACK_ENCORE_BIN) dev

webpack-watch: ## build & watch assets
webpack-watch:
	@$(WRAPPER_EXEC_USER) $(WEBPACK_ENCORE_BIN) dev --watch

.PHONY: webpack-build webpack-watch
