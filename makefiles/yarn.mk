YARN_BIN ?= yarn

##
## Yarn
## ----
##

yarn: ## run yarn
yarn:
	@$(WRAPPER_EXEC_USER) $(YARN_BIN) $(filter-out $@,$(MAKECMDGOALS))

yarn-install: ## run yarn install
yarn-install:
	@$(WRAPPER_EXEC_USER) $(YARN_BIN) install

yarn-upgrade: ## run yarn upgrade
yarn-upgrade:
	@$(WRAPPER_EXEC_USER) $(YARN_BIN) upgrade

.PHONY: yarn yarn-install yarn-upgrade
