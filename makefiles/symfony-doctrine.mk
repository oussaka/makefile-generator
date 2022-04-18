##
## Doctrine
## --------
##

dbdrop: ## Drop the database's content (tables, stored proc, etc.)
dbdrop:
	@$(SF) doc:schema:drop --force --full-database

dbcreate: ## Create the database schema
dbcreate:
	@$(SF) doc:database:create --if-not-exists

dbreset: ## Reset the database with schema from the current branch
dbreset: dbcreate dbdrop dbmigrate

dbreload: ## Reset the database with schema AND fixtures from the current branch
dbreload: dbreset dbfixtures

dbdiff: ## Create a new migration based on current schema
dbdiff:
	@$(SF) doc:mig:diff

dbmigrate: ## Execute the migrations
dbmigrate:
	@$(SF) doc:mig:mig -n

dbfixtures: ## Load dev fixtures
dbfixtures:
	@$(SF) ha:f:l -n

.PHONY: dbdrop dbcreate dbreset dbreload dbdiff dbmigrate dbfixtures
