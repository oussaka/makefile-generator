DOCKER_BIN ?= docker

ifeq ($(shell which $(DOCKER_BIN)),)

root: docker_error

app: docker_error

logs: docker_error

up: docker_error

stop: docker_error

down: docker_error

docker_error:
	$(error "docker actions are not available in the container")

.PHONY: docker_error

else

DOCKER_COMPOSE_BIN ?= docker-compose

PROJECT_NAME ?=
DC_EXEC_ROOT = $(DOCKER_COMPOSE_BIN) exec $(PROJECT_NAME)
DC_EXEC_USER = $(DOCKER_COMPOSE_BIN) exec --user=$$(id -u):$$(id -g) $(PROJECT_NAME)

##
## Docker-specific actions
## -----------------------
##

root: ## docker-compose exec (root)
root:
	@$(DC_EXEC_ROOT) $(filter-out $@,$(MAKECMDGOALS))

app: ## docker-compose exec on your application container
app:
	@$(DC_EXEC_USER) $(filter-out $@,$(MAKECMDGOALS))

logs: ## docker-compose logs -f
logs:
	@$(DOCKER_COMPOSE_BIN) logs -f $(filter-out $@,$(MAKECMDGOALS))

build: ## build docker environment
build:
	@$(DOCKER_COMPOSE_BIN) build

up: ## Create the containers (if needed) and launch them
up:
	@$(DOCKER_COMPOSE_BIN) up -d

stop: ## stop the containers
stop:
	@$(DOCKER_COMPOSE_BIN) stop

down: ## Stops containers and removes containers
down:
	@$(DOCKER_COMPOSE_BIN) down

endif

.PHONY: root_ex app ex logs build up stop down


