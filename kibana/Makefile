SHELL := /bin/bash

.PHONY: requirements
requirements:
	npm install

.PHONY: elasticsearch-url
elasticsearch-url:
	jq -r '.logs_elasticsearch_url' <(${DM_CREDENTIALS_REPO}/sops-wrapper -d ${DM_CREDENTIALS_REPO}/terraform/environments/${STAGE}.json)


.PHONY: elasticsearch-auth
elasticsearch-auth:
	jq '{ApiKey: .logs_elasticsearch_api_key}' <(${DM_CREDENTIALS_REPO}/sops-wrapper -d ${DM_CREDENTIALS_REPO}/terraform/environments/${STAGE}.json)

.PHONY: dump
dump:
	$(if ${STAGE},,$(error Must specify STAGE))
	./node_modules/elasticdump/bin/elasticdump \
	    --input https://$$(make -s elasticsearch-url)/.kibana \
	    --headers "$$(make -s elasticsearch-auth)" \
	    --output kibana-export.json

.PHONY: restore
restore:
	$(if ${STAGE},,$(error Must specify STAGE))
	./node_modules/elasticdump/bin/elasticdump \
	    --output https://$$(make -s elasticsearch-url)/.kibana \
	    --headers "$$(make -s elasticsearch-auth)" \
	    --input kibana-export.json
