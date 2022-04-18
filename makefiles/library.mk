PHP_VERSION ?= 7.2

PHP_BACKEND_RUN = docker run -i -t --rm \
                    -e COMPOSER_ALLOW_SUPERUSER=1 \
                    -e SSH_AUTH_SOCK=/tmp/agent.sock \
                    -v ${SSH_AUTH_SOCK}:/tmp/agent.sock \
                    -v ${PWD}:/srv/www/webservice \
                    --entrypoint /bin/bash \
                    --workdir /srv/www/webservice \
                    registry.intrardc.rdc/develop/php_backend:$(PHP_VERSION) \
                    -c

COMPOSER_BIN ?= composer

##
## Composer actions
## ----------------
##

composer-install: ## composer install
composer-install:
	@$(PHP_BACKEND_RUN) "$(COMPOSER_BIN) install"
	@$(MAKE) --no-print-directory chown-reset
	@$(MAKE) --no-print-directory fix-git-hooks

composer-update: ## composer update
composer-update:
	@$(PHP_BACKEND_RUN) "$(COMPOSER_BIN) update"
	@$(MAKE) --no-print-directory chown-reset
	@$(MAKE) --no-print-directory fix-git-hooks

##
## Git
## ---
##

fix-git-hooks: ## Fix git hooks
fix-git-hooks:
	@echo "Fixing GrumPHP hooks"
	@test -f .git/hooks/pre-commit || exit 0 && sed -i -r 's#$(PROJECT_DIR)/##g' .git/hooks/pre-commit
	@test -f .git/hooks/commit-msg || exit 0 && sed -i -r 's#$(PROJECT_DIR)/##g' .git/hooks/commit-msg

##
## Docker
## ------
##

backend-run: ## Run a command on a backend container
backend-run:
	@$(PHP_BACKEND_RUN) $(filter-out $@,$(MAKECMDGOALS))

.PHONY: composer-install composer-update backend
