.DEFAULT_GOAL := help
SHELL := /bin/bash
VIRTUALENV_ROOT := $(shell [ -z ${VIRTUAL_ENV} ] && echo $$(pwd)/venv || echo ${VIRTUAL_ENV})

PAAS_API ?= api.cloud.service.gov.uk
PAAS_ORG ?= digitalmarketplace
PAAS_SPACE ?= ${STAGE}

define check_space
	$(if ${PAAS_SPACE},,$(error Must specify PAAS_SPACE))
	@[ $$(cf target | grep -i 'space' | cut -d':' -f2) = "${PAAS_SPACE}" ] || (echo "${PAAS_SPACE} is not currently active cf space" && exit 1)
endef

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.PHONY: test
test: test_pep8 test_unit

.PHONY: test_pep8
test_pep8: virtualenv
	${VIRTUALENV_ROOT}/bin/pep8 .

.PHONY: test_unit
test_unit: virtualenv
	${VIRTUALENV_ROOT}/bin/py.test ${PYTEST_ARGS}

.PHONY: requirements
requirements: virtualenv ## Install requirements
	${VIRTUALENV_ROOT}/bin/pip install -r requirements.txt

.PHONY: virtualenv
virtualenv: ${VIRTUALENV_ROOT}/activate ## Create virtualenv if it does not exist

${VIRTUALENV_ROOT}/activate:
	@[ -z "${VIRTUAL_ENV}" ] && [ ! -d venv ] && virtualenv venv || true

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
	${DM_CREDENTIALS_REPO}/sops-wrapper -v > /dev/null # Avoid asking for MFA twice (when mandatory)
	${VIRTUALENV_ROOT}/bin/python scripts/generate-paas-manifest.py ${STAGE} ${APPLICATION_NAME} \
		-f <(${DM_CREDENTIALS_REPO}/sops-wrapper -d ${DM_CREDENTIALS_REPO}/vars/${STAGE}.yaml)

.PHONY: paas-login
paas-login: ## Log in to PaaS
	$(if ${PAAS_USERNAME},,$(error Must specify PAAS_USERNAME))
	$(if ${PAAS_PASSWORD},,$(error Must specify PAAS_PASSWORD))
	$(if ${PAAS_SPACE},,$(error Must specify PAAS_SPACE))
	@cf login -a "${PAAS_API}" -u ${PAAS_USERNAME} -p "${PAAS_PASSWORD}" -o "${PAAS_ORG}" -s "${PAAS_SPACE}"

.PHONY: deploy-app
deploy-app: ## Deploys the app to PaaS
	$(call check_space)
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	cf push -f <(make -s -C ${CURDIR} generate-manifest) -o digitalmarketplace/${APPLICATION_NAME}:${RELEASE_NAME}

	# TODO restore scaling before route switch once we have autoscaling set up
	# TODO for now, we're using the instance counts set in the manifest
	# cf scale -i $$(cf curl /v2/apps/$$(cf app --guid ${APPLICATION_NAME}-rollback) | jq -r ".entity.instances" 2>/dev/null || echo "1") ${APPLICATION_NAME}

	@if cf app ${APPLICATION_NAME} >/dev/null; then ./scripts/unmap-route.sh ${APPLICATION_NAME}; fi

	@echo "Waiting for previous app version to process existing requests..."
	sleep 60

	cf delete -f ${APPLICATION_NAME}
	cf rename ${APPLICATION_NAME}-release ${APPLICATION_NAME}

.PHONY: deploy-db-migration
deploy-db-migration: ## Deploys the db migration app
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	cf push ${APPLICATION_NAME}-db-migration -f <(make -s -C ${CURDIR} generate-manifest) -o digitalmarketplace/${APPLICATION_NAME}:${RELEASE_NAME} --no-route --health-check-type none -i 1 -m 128M -c 'sleep 2h'
	cf stop ${APPLICATION_NAME}-db-migration
	cf run-task ${APPLICATION_NAME}-db-migration "cd /app && python application.py db upgrade" --name ${APPLICATION_NAME}-db-migration

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
	$(eval export DUMP_FILE_NAME=${STAGE}-$(shell date +"%Y%m%d%H%M").sql.gz.gpg)
	$(eval export S3_POST_URL_DATA=$(shell ${VIRTUALENV_ROOT}/bin/python ./scripts/generate-s3-post-url-data.py digitalmarketplace-database-backups ${DUMP_FILE_NAME}))
	cf push db-backup -f <(make -s -C ${CURDIR} generate-manifest) -o digitalmarketplace/db-backup --no-route --health-check-type none -i 1 -m 128M -c 'sleep 2h'
	cf set-env db-backup DUMP_FILE_NAME '${DUMP_FILE_NAME}'
	cf set-env db-backup S3_POST_URL_DATA '${S3_POST_URL_DATA}'
	cf set-env db-backup RECIPIENT 'Digital Marketplace DB backups'
	cf set-env db-backup PUBKEY "$$(cat ${DM_CREDENTIALS_REPO}/gpg/database-backups/public.key)"
	cf restage db-backup
	cf run-task db-backup "/app/create-db-dump.sh" --name db-backup -m 2G

.PHONY: check-db-backup-task
check-db-backup-task: ## Get the status for the last db backup task
	@cf curl /v3/apps/`cf app --guid db-backup`/tasks?order_by=-created_at | jq -r ".resources[0].state"

.PHONY: cleanup-db-backup
cleanup-db-backup: ## Remove snapshot service and app
	cf delete -f db-backup

.PHONY: paas-clean
paas-clean: ## Cleans up all files created for the PaaS deployment
	cf logout

.PHONY: create-db-cleanup-service
create-db-cleanup-service: ## Create a db service for cleaning up latest dump to use in other environments.
	./scripts/create-db-cleanup-service.sh

.PHONY: check-db-cleanup-service
check-db-cleanup-service: ## Get the status for the db cleanup service
	@cf service digitalmarketplace_db_cleanup | grep -i 'status: ' | sed 's/^.*: //' | tr '[:lower:]' '[:upper:]'

.PHONY: deploy-db-cleanup-app
deploy-db-cleanup-app: ## Deploys the db cleanup app
	@[ $$(cf target | grep -i 'space' | cut -d':' -f2) = "db-cleanup" ] || (echo "Error: This can only be run in the db-cleanup space" && exit 1)
	cf push db-cleanup -o digitalmarketplace/db-cleanup --no-route --health-check-type none -i 1 -m 128M -c 'sleep 2h'
	cf bind-service db-cleanup digitalmarketplace_db_cleanup
	cf restage db-cleanup

.PHONY: import-and-clean-db-dump
import-and-clean-db-dump: ## Connects to the db-cleanup service, imports the latest dump and cleans it.
	 @[ $$(cf target | grep -i 'space' | cut -d':' -f2) = "db-cleanup" ] || (echo "Error: This can only be run in the db-cleanup space" && exit 1)
	 ./scripts/import-and-clean-db-dump.sh

.PHONY: populate-paas-db
populate-paas-db: ## Imports postgres dump specified with `DB_DUMP=` to targeted spaces db
	$(call check_space)
	$(if ${DB_DUMP},,$(error Must specify DB_DUMP))
	./scripts/populate-paas-db.sh ${DB_DUMP}
