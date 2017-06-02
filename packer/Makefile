define run_packer
    aws-auth packer build -var 'name=${1}' build.json
endef

.PHONY: elasticsearch
elasticsearch:
	$(call run_packer,elasticsearch)

.PHONY: nginx
nginx:
	$(call run_packer,nginx)

.PHONY: clean
clean:
	../scripts/clean-old-ami.sh
