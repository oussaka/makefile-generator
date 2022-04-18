makefile-generator
=============================

This library makes it possible to provide a list of common make commands in order to avoid rewriting the same commands everywhere.

The `vendor/bin/php-makefile-integration-cli` script allows you to make the include automatically according to what the system detects.

The `symfony-doctrine` script is never automatically included.

You can control automatic inclusions and exclusions with a `phpmakefile.conf` file in the root of your project.
This file must have the following form:

```json
{
  "include": ["symfony-doctrine"],
  "exclude": ["webpack"]
}
```

For the installation you have to declare variables at the beginning of `Makefile`:

- `PROJECT_NAME`: the name of your microservice (which must also be the name of your container at docker-compose level)
- `PROJECT_DIR`: the root directory of your application (if you plan to use `make` outside of the directory where the Makefile resides)

If you are using docker:
- `WRAPPER_EXEC`: set to `$(DC_EXEC_ROOT)`
- `WRAPPER_EXEC_USER`: set to `$(DC_EXEC_USER)`

Example:

```makefile
PROJECT_NAME = monservice-api

ifeq (, $(shell which docker-compose))
WRAPPER_EXEC =
WRAPPER_EXEC_USER =
else
WRAPPER_EXEC = $(DC_EXEC_ROOT)
WRAPPER_EXEC_USER = $(DC_EXEC_USER)
endif
```