
PROJECT_DIR ?= $(PWD)

#PROJECT_NAME = monservice-api

ifeq (, $(shell which docker-compose))
WRAPPER_EXEC =
WRAPPER_EXEC_USER =
else
WRAPPER_EXEC = $(DC_EXEC_ROOT)
WRAPPER_EXEC_USER = $(DC_EXEC_USER)
endif

##
## Makefile base
## -------------
##

chown-reset: ## reset the owner of all files in this directory and subdirectories
chown-reset:
	@echo "Resetting files rights to the project's user (might prompt super-user)"
	@sudo chown -R $$(id -u):$$(id -g) src vendor var
	@sudo chmod -R 777 var/*

.DEFAULT_GOAL := help
help: ## provide help to you
help:
	@grep -hE '(^[a-zA-Z._-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) \
	| grep -v "###>" \
	| grep -v "###<" \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

# @see https://stackoverflow.com/questions/6273608/how-to-pass-argument-to-makefile-from-command-line/6273809#6273809
%: # hack to make arguments with targets - use with $(filter-out $@,$(MAKECMDGOALS))
	@:

.PHONY: chown-reset help %
