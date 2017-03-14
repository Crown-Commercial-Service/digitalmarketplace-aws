.DEFAULT_GOAL := help
SHELL := /bin/bash
VIRTUALENV_ROOT := $(shell [ -z ${VIRTUAL_ENV} ] && echo $$(pwd)/venv || echo ${VIRTUAL_ENV})

PAAS_API ?= api.cloud.service.gov.uk
PAAS_ORG ?= digitalmarketplace
PAAS_SPACE ?= ${STAGE}

DEPLOYMENT_DIR := ${CURDIR}/tmp
CF_HOME ?= ${DEPLOYMENT_DIR}
$(eval export CF_HOME)

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: requirements
requirements: ## Install requirements
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
	mkdir -p ${DEPLOYMENT_DIR}
	${VIRTUALENV_ROOT}/bin/dmaws paas-manifest ${STAGE} ${APPLICATION_NAME} \
		-f <(${DM_CREDENTIALS_REPO}/sops-wrapper -d ${DM_CREDENTIALS_REPO}/vars/common.yaml) \
		-f <(${DM_CREDENTIALS_REPO}/sops-wrapper -d ${DM_CREDENTIALS_REPO}/vars/${STAGE}.yaml) \
		-o ${DEPLOYMENT_DIR}/manifest.yml

.PHONY: paas-login
paas-login: ## Log in to PaaS
	$(if ${PAAS_USERNAME},,$(error Must specify PAAS_USERNAME))
	$(if ${PAAS_PASSWORD},,$(error Must specify PAAS_PASSWORD))
	$(if ${PAAS_SPACE},,$(error Must specify PAAS_SPACE))
	mkdir -p ${CF_HOME}
	@cf login -a "${PAAS_API}" -u ${PAAS_USERNAME} -p "${PAAS_PASSWORD}" -o "${PAAS_ORG}" -s "${PAAS_SPACE}"

.PHONY: paas-deploy
paas-deploy: ## Deploys the app to PaaS
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	cd ${DEPLOYMENT_DIR} && \
		cf app --guid ${APPLICATION_NAME} && \
		cf rename ${APPLICATION_NAME} ${APPLICATION_NAME}-rollback && \
		cf push -f manifest.yml && \
		cf scale -i $$(cf curl /v2/apps/$$(cf app --guid ${APPLICATION_NAME}) | jq -r ".entity.instances" && \ 2>/dev/null || echo "1") ${APPLICATION_NAME} && \
		cf stop ${APPLICATION_NAME}-rollback && \
		cf delete -f ${APPLICATION_NAME}-rollback

.PHONY: paas-rollback
paas-rollback: ## Rollbacks the app to the previous release on PaaS
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	cd ${DEPLOYMENT_DIR} && \
		cf app --guid notify-admin-rollback && \
		cf delete -f notify-admin && \
		cf rename notify-admin-rollback notify-admin

.PHONY: paas-push
paas-push: ## Pushes the app to PaaS
	$(if ${APPLICATION_NAME},,$(error Must specify APPLICATION_NAME))
	cd ${DEPLOYMENT_DIR} && \
		cf push ${APPLICATION_NAME} -f manifest.yml

.PHONY: paas-clean
paas-clean: ## Cleans up all files created for the PaaS deployment
	rm -rf ${DEPLOYMENT_DIR}
