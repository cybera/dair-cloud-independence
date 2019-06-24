CURDIR := $(shell pwd)
UNAME = $(shell uname)
TF_PATH := $(CURDIR)/terraform
export PATH := $(CURDIR)/bin:$(CURDIR)/bin/$(UNAME):$(PATH)

# Global tasks
help: tasks

tasks:
	@grep -A1 ^HELP Makefile | sed -e ':begin;$$!N;s/HELP: \(.*\)\n\(.*:\).*/\2 \1/;tbegin;P;D' | grep -v ^\\\-\\\- | sort | awk -F: '{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

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

HELP: Runs "terraform version"
version:
	@cd bin/$(UNAME); terraform --version

HELP: Runs "terraform init" for \$ENV
init: check-env
	@cd $(TF_PATH)/$(ENV); terraform init

HELP: Runs "terraform plan" for \$ENV
plan: check-env init
	@cd $(TF_PATH)/$(ENV); terraform plan

HELP: Runs "terraform apply" for \$ENV
apply: check-env plan
	@cd $(TF_PATH)/$(ENV); terraform apply

HELP: Runs "terraform apply -auto-approve" for \$ENV
auto-apply: check-env plan
	@cd $(TF_PATH)/$(ENV); terraform apply -auto-approve

HELP: Runs "terraform taint" for \$ENV
taint: check-env
	@cd $(TF_PATH)/$(ENV); terraform taint

HELP: Runs "terraform show" for \$ENV
show: check-env
	@cd $(TF_PATH)/$(ENV); terraform show

HELP: Runs "terraform destroy" for \$ENV
destroy: check-env
	@cd $(TF_PATH)/$(ENV); terraform destroy -force

HELP: Generates an SSH key
create-sshkey:
	@cd key && ssh-keygen -t rsa -N '' -f id_rsa
