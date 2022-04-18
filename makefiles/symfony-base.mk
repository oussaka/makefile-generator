WRAPPER_EXEC_USER ?=
APP_ENV ?= dev
SF ?= $(WRAPPER_EXEC_USER) bin/console --env=$(APP_ENV)

##
## Symfony's actions
## -----------------
##

sf: ## Symfony bin
sf:
	@$(SF) $(filter-out $@,$(MAKECMDGOALS))

cc: ## Symfony Clear cache
cc:
	@$(SF) cache:clear --no-warmup
	@$(SF) cache:warmup

purge: ## Purge cache and logs
purge:
	@rm -rf var/cache/* var/logs/*

.PHONY: cc sf purge
