CURDIR := $(shell pwd)
UNAME = $(shell uname)
TF_PATH := $(CURDIR)/terraform
export PATH := $(CURDIR)/bin:$(CURDIR)/bin/$(UNAME):$(PATH)

# Checks
check-env:
ifndef ENV
	$(error ENV is not defined)
endif

check-args:
ifdef ARGS
export _ARGS = -a "$(ARGS)"
else
export _ARGS =
endif

version:
	@cd bin/$(UNAME); terraform --version

init: check-env
	@cd $(TF_PATH)/$(ENV); terraform init

plan: check-env init
	@cd $(TF_PATH)/$(ENV); terraform plan

apply: check-env plan
	@cd $(TF_PATH)/$(ENV); terraform apply

auto-apply: check-env plan
	@cd $(TF_PATH)/$(ENV); terraform apply -auto-approve

taint: check-env
	@cd $(TF_PATH)/$(ENV); terraform taint

show: check-env
	@cd $(TF_PATH)/$(ENV); terraform show

destroy: check-env
	@cd $(TF_PATH)/$(ENV); terraform destroy -force

create-sshkey:
	@cd key && ssh-keygen -t rsa -N '' -f id_rsa

get-public-ip:
	@cd $(TF_PATH)/$(ENV); terraform show -no-color | grep 'public_ip =' | cut -d= -f2 | tr -d \" | tr -d ' '

ssh:
	@_public_ip=$(shell make get-public-ip ENV=$(ENV)) ; \
	ssh -i key/id_rsa ubuntu@$$_public_ip

deploy_app: check-env
	@cd $(TF_PATH)/$(ENV); terraform taint module.deploy_app.null_resource.copy_files; terraform apply

restart_app: check-env
	@_public_ip=$(shell make get-public-ip ENV=$(ENV)) ; \
	ssh -i key/id_rsa ubuntu@$$_public_ip "cd apps/docker_files && sudo docker-compose down && sudo docker-compose up -d"
