local: ## Start the application (pnpm) in dev mode
	@echo 'Starting containers'
	docker compose \
		--profile application \
		--project-name infrastructure \
		-f ./environments/local/docker-compose.yml \
		up -d

	@echo 'Container IDs and Names:'
	@docker ps --format "table {{.ID}}\t{{.Names}}"
	@echo 'Run to follow logs: docker logs -f CONTAINER'

stop: ## Stop complete the application
	@echo 'Stopping containers'
	docker compose --project-name infrastructure down