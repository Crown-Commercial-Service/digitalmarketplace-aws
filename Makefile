.DEFAULT_GOAL := help
SHELL := /bin/bash
VIRTUALENV_ROOT := $(shell [ -z ${VIRTUAL_ENV} ] && echo $$(pwd)/venv || echo ${VIRTUAL_ENV})
export PATH := ${VIRTUALENV_ROOT}/bin:${PATH}

PAAS_API ?= api.cloud.service.gov.uk
PAAS_ORG ?= digitalmarketplace
PAAS_SPACE ?= ${STAGE}

POSTGRES_NAME ?= dm_db_tmp

define check_space
	$(if ${PAAS_SPACE},,$(error Must specify PAAS_SPACE))
	@[ $$(cf target | grep -i 'space' | cut -d':' -f2) = "${PAAS_SPACE}" ] || (echo "${PAAS_SPACE} is not currently active cf space" && exit 1)
endef

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.PHONY: test
test: test-flake8 test-unit

.PHONY: terraformat
terraformat:
	terraform fmt -list=true -diff=true -write=true terraform

.PHONY: terraformatest
terraformatest:
	./scripts/check-terraform-formatting.sh

.PHONY: test-flake8
test-flake8: virtualenv
	${VIRTUALENV_ROOT}/bin/flake8 .

.PHONY: test-unit
test-unit: virtualenv
	${VIRTUALENV_ROOT}/bin/py.test ${PYTEST_ARGS}

.PHONY: requirements
requirements: virtualenv requirements.txt
	${VIRTUALENV_ROOT}/bin/pip install -r requirements.txt

.PHONY: requirements-dev
requirements-dev: virtualenv requirements-dev.txt
	${VIRTUALENV_ROOT}/bin/pip install -r requirements-dev.txt

.PHONY: virtualenv
virtualenv: ${VIRTUALENV_ROOT}/activate ## Create virtualenv if it does not exist

${VIRTUALENV_ROOT}/activate:
	@[ -z "${VIRTUAL_ENV}" ] && [ ! -d venv ] && python3 -m venv venv || true

.PHONY: preview
preview: ## Set stage to preview
	$(eval export STAGE=preview)
	@true

.PHONY: staging
staging: ## Set stage to staging
	$(eval export STAGE=staging)
	@true

.PHONY: production
production: ## Set stage to production
	$(eval export STAGE=production)
	@true

.PHONY: generate-manifest
generate-manifest: virtualenv ## Generate manifest file for PaaS
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	$(if ${STAGE},,$(error Must specify STAGE))
	$(if ${DM_CREDENTIALS_REPO},,$(error Must specify DM_CREDENTIALS_REPO))
	@${DM_CREDENTIALS_REPO}/sops-wrapper -v > /dev/null # Avoid asking for MFA twice (when mandatory)
	@${VIRTUALENV_ROOT}/bin/python scripts/generate-paas-manifest.py ${STAGE} ${APPLICATION_NAME} \
		-f <(${DM_CREDENTIALS_REPO}/sops-wrapper -d ${DM_CREDENTIALS_REPO}/vars/${STAGE}.yaml) \
		${ARGS}

.PHONY: paas-login
paas-login: ## Log in to PaaS
	$(if ${PAAS_USERNAME},,$(error Must specify PAAS_USERNAME))
	$(if ${PAAS_PASSWORD},,$(error Must specify PAAS_PASSWORD))
	$(if ${PAAS_SPACE},,$(error Must specify PAAS_SPACE))
	@cf login -a "${PAAS_API}" -u ${PAAS_USERNAME} -p "${PAAS_PASSWORD}" -o "${PAAS_ORG}" -s "${PAAS_SPACE}"

.PHONY: add-all-app-network-policies
add-all-app-network-policies: ## attempts to (re-)add all known PaaS "network policies" suitable for a particular $STAGE
	$(call check_space)
	$(if ${STAGE},,$(error Must specify STAGE))
	for APPLICATION_NAME in $$(yq -rs '.[0] * .[1] | to_entries | .[] | select(.value | has("egress_to_applications"))? | .key' ./vars/common.yml ./vars/${STAGE}.yml) ; do \
		./scripts/add-application-network-policies.sh ./vars/$${STAGE}.yml ./vars/common.yml $${APPLICATION_NAME} ; \
	done

.PHONY: deploy-app
deploy-app: ## Deploys the app to PaaS
	$(call check_space)
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	$(if ${RELEASE_NAME},,$(error Must specify RELEASE_NAME))
	$(if ${STAGE},,$(error Must specify STAGE))
	$(if ${CF_DOCKER_PASSWORD},,$(error Must specify CF_DOCKER_PASSWORD))
	$(if ${DOCKER_USERNAME},,$(error Must specify DOCKER_USERNAME))
	cf push --no-start --no-route -f <(make -s -C ${CURDIR} generate-manifest) -o digitalmarketplace/${APPLICATION_NAME}:${RELEASE_NAME} --docker-username ${DOCKER_USERNAME}

	@echo "Waiting to ensure new app's assigned service credentials have taken effect..."
	sleep 60

	@echo "Starting app..."
	cf start ${APPLICATION_NAME}-release

	# TODO restore scaling before route switch once we have autoscaling set up
	# TODO for now, we're using the instance counts set in the manifest
	# cf scale -i $$(cf curl /v2/apps/$$(cf app --guid ${APPLICATION_NAME}-rollback) | jq -r ".entity.instances" 2>/dev/null || echo "1") ${APPLICATION_NAME}

	# Create the route for the release app
	./scripts/map-route.sh ${APPLICATION_NAME}-release <(make -s -C ${CURDIR} generate-manifest)

	# Make sure relevant routes are whitelisted (can be found in vars/ip_whitelist_routes.json)
	./scripts/add-ip-whitelist-route-service.sh ${STAGE} ${APPLICATION_NAME}

	# Delete the route for the old app
	@if cf app ${APPLICATION_NAME} >/dev/null; then ./scripts/unmap-route.sh ${APPLICATION_NAME}; fi

	@echo "Waiting for previous app version to process existing requests..."
	sleep 60

	-cf stop ${APPLICATION_NAME}
	-cf delete -f ${APPLICATION_NAME}
	cf rename ${APPLICATION_NAME}-release ${APPLICATION_NAME}

.PHONY: deploy-db-migration
deploy-db-migration: ## Deploys the db migration app
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	cf push ${APPLICATION_NAME}-db-migration -f <(make -s -C ${CURDIR} generate-manifest APPLICATION_NAME=db-migration) -o digitalmarketplace/${APPLICATION_NAME}:${RELEASE_NAME} --no-route
	cf stop ${APPLICATION_NAME}-db-migration
	cf run-task ${APPLICATION_NAME}-db-migration "cd /app && FLASK_APP=application:application venv/bin/flask db upgrade" --name ${APPLICATION_NAME}-db-migration

.PHONY: check-db-migration-task
check-db-migration-task: ## Get the status for the last db migration task
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	@cf curl /v3/apps/`cf app --guid ${APPLICATION_NAME}-db-migration`/tasks?order_by=-created_at | jq -r ".resources[0].state"

.PHONY: create-db-snapshot-service
create-db-snapshot-service: ## Create a db service from the latest db snapshot
	$(eval export DB_GUID=$(shell cf service digitalmarketplace_api_db --guid))
	$(eval export DB_PLAN=$(shell cf service digitalmarketplace_api_db | grep -i 'plan: ' | cut -d ' ' -f2))
	cf create-service postgres ${DB_PLAN} digitalmarketplace_api_db_snapshot -c "{\"restore_from_latest_snapshot_of\": \"${DB_GUID}\"}"

.PHONY: check-db-snapshot-service
check-db-snapshot-service: ## Get the status for the db snapshot service
	@cf service digitalmarketplace_api_db_snapshot | grep -i 'status: ' | sed 's/^.*: //' | tr '[:lower:]' '[:upper:]'

.PHONY: deploy-db-backup-app
deploy-db-backup-app: virtualenv ## Deploys the db backup app
	$(eval export APPLICATION_NAME=db-backup)
	$(if ${DUMP_FILE_NAME},,$(error Must specify DUMP_FILE_NAME as '<stage>-yyyyMMddHHmm.sql.gz.gpg'))   # Supplied by Jenkins job context
	$(eval export S3_POST_URL_DATA=$(shell ${VIRTUALENV_ROOT}/bin/python ./scripts/generate-s3-post-url-data.py digitalmarketplace-database-backups ${DUMP_FILE_NAME}))

	# Deploy the backup app
	cf push db-backup -f <(make -s -C ${CURDIR} generate-manifest ARGS="-v DUMP_FILE_NAME -v S3_POST_URL_DATA") -o digitalmarketplace/db-backup --no-route
	cf set-env db-backup PUBKEY "$$(cat ${DM_CREDENTIALS_REPO}/gpg/database-backups/public.key)"
	cf restage db-backup

	# Run the backup script in a separate task container. This has its own disk and memory quotas, but inherits the db-backup app's context vars.
	cf run-task db-backup "/app/create-db-dump.sh" --name db-backup -m 5G -k 5G

.PHONY: check-db-backup-task
check-db-backup-task: ## Get the status for the last db backup task
	@cf curl /v3/apps/`cf app --guid db-backup`/tasks?order_by=-created_at | jq -r ".resources[0].state"

.PHONY: cleanup-db-backup
cleanup-db-backup: ## Remove snapshot service and app
	cf delete -f db-backup

.PHONY: paas-clean
paas-clean: ## Cleans up all files created for the PaaS deployment
	-cf logout

.PHONY: run-postgres-container
run-postgres-container: ## Runs a postgres container
	$(if ${POSTGRES_PASSWORD},,$(error Must specify POSTGRES_PASSWORD))

	# clean up existing container if any
	docker stop ${POSTGRES_NAME} || true
	docker rm -v ${POSTGRES_NAME} || true

	docker run -d -p 63306:5432 -e POSTGRES_PASSWORD --name ${POSTGRES_NAME} postgres:9.5-alpine

.PHONY: import-and-clean-db-dump
import-and-clean-db-dump: virtualenv ## Connects to the postgres container, imports the latest dump and cleans it.
	VIRTUALENV_ROOT=${VIRTUALENV_ROOT} ./scripts/import-and-clean-db-dump.sh

.PHONY: apply-cleaned-db-dump
apply-cleaned-db-dump: ## Migrate the cleaned db dump to a target stage and sync with s3.
	./scripts/apply-cleaned-db-to-target.sh

.PHONY: cleanup-postgres-container
cleanup-postgres-container: ## Stop and remove the docker container and its volume
	docker stop ${POSTGRES_NAME}
	docker rm -v ${POSTGRES_NAME}

.PHONY: populate-paas-db
populate-paas-db: ## Imports postgres dump specified with `DB_DUMP=` to targeted spaces db
	$(call check_space)
	$(if ${DB_DUMP},,$(error Must specify DB_DUMP))
	./scripts/populate-paas-db.sh ${DB_DUMP}
