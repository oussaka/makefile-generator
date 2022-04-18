CODECEPT_BIN ?= vendor/bin/codecept

##
## Tests
## -----
##

test: ## Launches all tests
test:
	@$(WRAPPER_EXEC_USER) $(CODECEPT_BIN) run

codecept: ## Run codeception. Please provide arguments.
codecept:
	@$(WRAPPER_EXEC_USER) $(CODECEPT_BIN) $(filter-out $@,$(MAKECMDGOALS))

.PHONY: test codecept
