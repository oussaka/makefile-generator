WRAPPER_EXEC_USER ?=
BEHAT_BIN=$(EXEC) vendor/bin/behat
BEHAT_ARGS?=-vv

##
## Behat, functional tests actions
## --------------------------------
##

test-behat: ## Run behat tests
test-behat:
	@$(eval tags ?= '~')
	@$(WRAPPER_EXEC_USER) $(BEHAT_BIN) --tags=$(tags) $(BEHAT_ARGS)

test: test-phpunit test-behat ## Run the PHP and Behat tests

.PHONY: test test-behat test-phpunit
