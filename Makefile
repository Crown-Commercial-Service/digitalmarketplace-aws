.DEFAULT_GOAL := help
SHELL := /bin/bash
VIRTUALENV_ROOT := $(shell [ -z ${VIRTUAL_ENV} ] && echo $$(pwd)/venv || echo ${VIRTUAL_ENV})

PAAS_API ?= api.cloud.service.gov.uk
PAAS_ORG ?= digitalmarketplace
PAAS_SPACE ?= ${STAGE}

DEPLOYMENT_DIR := ${CURDIR}/tmp

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: requirements
requirements: virtualenv ## Install requirements
	${VIRTUALENV_ROOT}/bin/pip install -e .

.PHONY: virtualenv
virtualenv: ${VIRTUALENV_ROOT}/activate ## Create virtualenv if it does not exist

${VIRTUALENV_ROOT}/activate:
	@[ -z "${VIRTUAL_ENV}" ] && [ ! -d venv ] && virtualenv venv || true

.PHONY: build
build: requirements ## Build project

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

download-deployment-zip: virtualenv ## Downloads the deployment zip file from S3
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	$(if ${RELEASE_NUMBER},,$(error Must specify RELEASE_NUMBER))
	rm -rf ${DEPLOYMENT_DIR}
	mkdir ${DEPLOYMENT_DIR}
	${VIRTUALENV_ROOT}/bin/aws s3 --only-show-errors cp --region eu-west-1 s3://digitalmarketplace-deployment/${APPLICATION_NAME}/release-${RELEASE_NUMBER}.zip ${DEPLOYMENT_DIR}/release.zip
	unzip -q -d ${DEPLOYMENT_DIR} ${DEPLOYMENT_DIR}/release.zip
	rm ${DEPLOYMENT_DIR}/release.zip

.PHONY: paas-generate-manifest
paas-generate-manifest: virtualenv ## Generate manifest file for PaaS
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	$(if ${STAGE},,$(error Must specify STAGE))
	$(if ${DM_CREDENTIALS_REPO},,$(error Must specify DM_CREDENTIALS_REPO))
	${DM_CREDENTIALS_REPO}/sops-wrapper -v > /dev/null # Avoid asking for MFA twice (when mandatory)
	${VIRTUALENV_ROOT}/bin/dmaws paas-manifest ${STAGE} ${APPLICATION_NAME} \
		-f <(${DM_CREDENTIALS_REPO}/sops-wrapper -d ${DM_CREDENTIALS_REPO}/vars/common.yaml) \
		-f <(${DM_CREDENTIALS_REPO}/sops-wrapper -d ${DM_CREDENTIALS_REPO}/vars/${STAGE}.yaml)

.PHONY: paas-login
paas-login: ## Log in to PaaS
	$(if ${PAAS_USERNAME},,$(error Must specify PAAS_USERNAME))
	$(if ${PAAS_PASSWORD},,$(error Must specify PAAS_PASSWORD))
	$(if ${PAAS_SPACE},,$(error Must specify PAAS_SPACE))
	@cf login -a "${PAAS_API}" -u ${PAAS_USERNAME} -p "${PAAS_PASSWORD}" -o "${PAAS_ORG}" -s "${PAAS_SPACE}"

.PHONY: paas-build
paas-build: ## Build the PaaS application
	cp paas/run.sh ${DEPLOYMENT_DIR}/run.sh
	chmod +x ${DEPLOYMENT_DIR}/run.sh

.PHONY: paas-deploy
paas-deploy: paas-build ## Deploys the app to PaaS
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	cd ${DEPLOYMENT_DIR} && \
		cf app --guid ${APPLICATION_NAME} && \
		cf rename ${APPLICATION_NAME} ${APPLICATION_NAME}-rollback && \
		cf push -f <(make -s -C ${CURDIR} paas-generate-manifest) && \
		cf scale -i $$(cf curl /v2/apps/$$(cf app --guid ${APPLICATION_NAME}-rollback) | jq -r ".entity.instances" 2>/dev/null || echo "1") ${APPLICATION_NAME} && \
		cf stop ${APPLICATION_NAME}-rollback && \
		cf delete -f ${APPLICATION_NAME}-rollback

.PHONY: paas-deploy-db-migration
paas-deploy-db-migration: paas-build ## Deploys the db migration app
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	cd ${DEPLOYMENT_DIR} && \
		cf push ${APPLICATION_NAME}-db-migration -f <(make -s -C ${CURDIR} paas-generate-manifest) --no-route --health-check-type none -i 1 -m 128M -c 'sleep infinity' && \
		cf run-task ${APPLICATION_NAME}-db-migration "python application.py db upgrade" --name ${APPLICATION_NAME}-db-migration

.PHONY: paas-check-db-migration-task
paas-check-db-migration-task: ## Get the status for the last db migration task
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	@cf curl /v3/apps/`cf app --guid ${APPLICATION_NAME}-db-migration`/tasks?order_by=-created_at | jq -r ".resources[0].state"

.PHONY: paas-rollback
paas-rollback: ## Rollbacks the app to the previous release on PaaS
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	@[ $$(cf curl /v2/apps/`cf app --guid ${APPLICATION_NAME}-rollback` | jq -r ".entity.state") = "STARTED" ] || (echo "Error: rollback is not possible because ${APPLICATION_NAME}-rollback is not in a started state" && exit 1)
	cd ${DEPLOYMENT_DIR} && \
		cf app --guid ${APPLICATION_NAME}-rollback && \
		cf delete -f ${APPLICATION_NAME} && \
		cf rename ${APPLICATION_NAME}-rollback ${APPLICATION_NAME}

.PHONY: paas-push
paas-push: paas-build ## Pushes the app to PaaS
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	cd ${DEPLOYMENT_DIR} && \
		cf push -f <(make -s -C ${CURDIR} paas-generate-manifest)

.PHONY: paas-clean
paas-clean: ## Cleans up all files created for the PaaS deployment
	rm -rf ${DEPLOYMENT_DIR}
	cf logout
