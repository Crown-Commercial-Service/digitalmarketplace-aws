define run_packer
    aws-auth packer build -var 'name=${1}' build.json
endef

.PHONY: nginx
nginx:
	$(call run_packer,nginx)

.PHONY: clean
clean:
	../scripts/clean-old-ami.sh
