COMPOSER_BIN ?= composer

##
## Composer actions
## ----------------
##

composer: ## composer bin
composer:
	@$(WRAPPER_EXEC) $(COMPOSER_BIN) $(filter-out $@,$(MAKECMDGOALS))
	@$(MAKE) --no-print-directory chown-reset
	# @$(MAKE) --no-print-directory fix-git-hooks

composer-install: ## composer install the project PHP dependencies
composer-install:
	@$(WRAPPER_EXEC) $(COMPOSER_BIN) install
	@$(MAKE) --no-print-directory chown-reset
	# @$(MAKE) --no-print-directory fix-git-hooks

composer-update: ## composer update
composer-update:
	@$(WRAPPER_EXEC) $(COMPOSER_BIN) update
	@$(MAKE) --no-print-directory chown-reset
	# @$(MAKE) --no-print-directory fix-git-hooks

vendor: composer.json composer.lock
	@$(MAKE) composer-install

composer.lock: composer.json
	@echo composer.lock is not up to date.

.PHONY: composer composer-install composer-update vendor
