WRAPPER_EXEC_USER ?=
NPM_BIN ?= npm

##
## NPM actions
## -----------
##

npm-install: ## run npm install
npm-install:
	@$(WRAPPER_EXEC_USER) $(NPM_BIN) install --no-bin-links

.PHONY: npm-install
