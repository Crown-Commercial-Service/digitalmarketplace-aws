SHELL := /bin/bash

.PHONY: requirements
requirements:
	npm install

.PHONY: elasticsearch-url
elasticsearch-url:
	${DM_CREDENTIALS_REPO}/sops-wrapper -d ${DM_CREDENTIALS_REPO}/terraform/environments/${STAGE}.tfvars | sed -En '/^logs_elasticsearch_url/{s/.*= "(.+)"/\1/p}'


.PHONY: elasticsearch-auth
elasticsearch-auth:
	${DM_CREDENTIALS_REPO}/sops-wrapper -d ${DM_CREDENTIALS_REPO}/terraform/environments/${STAGE}.tfvars | sed -En '/^logs_elasticsearch_api_key/{s/.*= "(.+)"/\1/p}'

.PHONY: dump
dump:
	$(if ${STAGE},,$(error Must specify STAGE))
	./node_modules/elasticdump/bin/elasticdump \
	    --input https://$$(make -s elasticsearch-url)/.kibana \
	    --headers "{\"ApiKey\": \"$$(make -s elasticsearch-auth)\"}" \
	    --output kibana-export.json

.PHONY: restore
restore:
	$(if ${STAGE},,$(error Must specify STAGE))
	./node_modules/elasticdump/bin/elasticdump \
	    --output https://$$(make -s elasticsearch-url)/.kibana \
	    --headers "{\"ApiKey\": \"$$(make -s elasticsearch-auth)\"}" \
	    --input kibana-export.json
