.PHONY: build dev_bash help env_int env_prod deploy

.DEFAULT_GOAL := help

###############################################################################
# Variables
###############################################################################
DOCKER_COMPOSE := docker-compose -f docker-compose.yml -f docker-compose.dev.yml
DJANGO_MANAGE := ./manage.py

###############################################################################
# Dev tasks
###############################################################################
build:  ## Build docker images
	${DOCKER_COMPOSE} build

up: build   ## Start docker images
	${DOCKER_COMPOSE} up

dev_dependencies: build ## Start database, redis, celery and celery-beat images in daemon mode
	${DOCKER_COMPOSE} up -d db redis celery celery-beat

dev_bash: dev_dependencies ## Start a sarah image with Shell
	${DOCKER_COMPOSE} run --rm --publish 8000:8000 web /bin/sh

stop:	## Stop docker images
	${DOCKER_COMPOSE} stop

clear_docker_images:  ## Clear all docker volumes (effectively clears the database)
	${DOCKER_COMPOSE} down --volumes

###############################################################################
# Deploy tasks
###############################################################################
dev_prepare:  ## Install mandatory dependencies to be able to deploy
	@echo "========== Updating ansible dependencies ========== "
	ansible-galaxy install -r ansible/requirements.yml
	@echo "========== Configuring dev environment ========== "
	ansible-playbook --extra-vars "deploy_site=dev" --connection=local --inventory ansible/inventories/dev --tags dev ansible/site.yml



env_int:  ## Set env variables for the integration deployment
	$(eval APP_INVENTORY := "int")
	$(eval APP_DEPLOY_SITE := "test.sarah.fr")
	@echo env=${APP_INVENTORY}, deploy_site=${APP_DEPLOY_SITE}


deploy:  ## Deploys to the configured env (Prefix by env_* target!)
	ansible-playbook  --inventory=ansible/inventories/${APP_INVENTORY} ansible/site.yml --extra-vars "deploy_site=${APP_DEPLOY_SITE}"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

###############################################################################
# Following targets should be executed *inside* the web image
###############################################################################


runserver:  ## Start Django runserver
	${DJANGO_MANAGE} runserver 0.0.0.0:8000
