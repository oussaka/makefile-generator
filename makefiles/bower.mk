WRAPPER_EXEC_USER ?=
BOWER_BIN ?= ./node_modules/bower/bin/bower

##
## Bower actions
## -------------
##

bower: ## install bower dependencies
bower:
	@$(WRAPPER_EXEC_USER) $(BOWER_BIN) install

.PHONY: bower
