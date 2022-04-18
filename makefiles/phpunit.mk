
PHPUNIT_BIN ?= vendor/bin/phpunit
SIMPLE_PHPUNIT_BIN ?= vendor/bin/simple-phpunit
PHPUNIT_ARGS?=-v
PHPCSFIXER ?= vendor/bin/php-cs-fixer
APP_ENV ?= dev
CONSOLE ?= $(WRAPPER_EXEC_USER) bin/console --env=$(APP_ENV)

##
## Tests, lint and phpcs actions
## -----------------------------
##

simple-phpunit: ## Run simple-phpunit tests. Please provide arguments.
simple-phpunit: vendor
	@$(WRAPPER_EXEC_USER) $(SIMPLE_PHPUNIT_BIN) $(filter-out $@,$(MAKECMDGOALS))

test-phpunit: ## Run phpunit tests with stop-on-failure
test-phpunit: vendor
	@$(eval testsuite ?= 'all')
	@$(eval filter ?= '.')
	@$(WRAPPER_EXEC_USER) $(PHPUNIT_BIN) --testsuite=$(testsuite) --filter=$(filter) -d xdebug.mode=debug \
		--coverage-text --stop-on-failure --verbose --colors=auto

phpunit-coverage: ## Run PHPUnit test suite for coverage
phpunit-coverage: vendor
	$(WRAPPER_EXEC_USER) $(PHPUNIT_BIN) -d xdebug.mode=coverage -d xdebug.profiler_enable=on -d memory_limit=-1 --verbose \
		--coverage-html=/usr/src/app/tests/coverage \
		--coverage-text --colors=never

ly:
	$(CONSOLE) lint:yaml config --parse-tags

lt:
ifneq ($(wildcard template/.*),)
		$(CONSOLE) lint:twig --show-deprecations templates/
else
		@echo "Did not find templates/.*"
endif

lc:
	$(CONSOLE) lint:container

ls: ## Lint Symfony (Twig and YAML) files
ls: ly lt lc

phpcs-fixer: ## Lint PHP code with phpcs-fixer
phpcs-fixer: vendor
	@$(WRAPPER_EXEC_USER) $(PHPCSFIXER) fix --config=.php-cs-fixer.dist.php --allow-risky=yes --diff --dry-run --no-interaction -v

phpcs-fixer-apply: ## Lint and fix PHP code to follow the convention
phpcs-fixer-apply: vendor
ifeq ($(TARGET_PHPCSFIXER),default)
	@$(WRAPPER_EXEC_USER) $(PHPCSFIXER) fix --config=.php-cs-fixer.dist.php --allow-risky=yes --using-cache=no --verbose --diff
else
	@$(WRAPPER_EXEC_USER) $(PHPCSFIXER) fix $(TARGET_PHPCSFIXER) --config=.php-cs-fixer.dist.php --allow-risky=yes --using-cache=no --verbose --diff
endif

security-check: ## Check for vulnerable dependencies
security-check: vendor
	$(EXEC) local-php-security-checker --path=/app

lint: ## Run lint on Twig, YAML and PHP
lint: ls phpcs-fixer

.PHONY: phpunit test-phpunit phpunit-coverage lint ly lt lc ls phpcs-fixer phpcs-fixer-apply security-check
