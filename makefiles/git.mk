##
## Git
## ---
##

fix-git-hooks: ## Fix git hooks
fix-git-hooks:
	@echo "Fixing GrumPHP hooks"
	@test -f .git/hooks/pre-commit || exit 0 && sed -i -r 's#$(PROJECT_DIR)/##g' .git/hooks/pre-commit
	@test -f .git/hooks/commit-msg || exit 0 && sed -i -r 's#$(PROJECT_DIR)/##g' .git/hooks/commit-msg

install_hook: 																							## Install git hook for project
	echo "#!/bin/sh" > ./.git/hooks/pre-commit
	echo "make pre-commit-hooks" >> ./.git/hooks/pre-commit
	chmod +x ./.git/hooks/pre-commit

pre-commit-hooks:
	$(RUN) bin/php-cs-fixer-hooks.sh "$(CHANGED_FILES)" hooks

.PHONY: fix-git-hooks install_hook pre-commit-hooks
