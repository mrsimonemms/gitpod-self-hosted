INFRA_PROVIDERS_DIR = ./infrastructure/providers
WORKSPACE ?= default
WORKSPACE_PREFIX ?= gitpod-sh-

export TF_WORKSPACE = ${WORKSPACE_PREFIX}${WORKSPACE}

hetzner-init:
	terraform \
		-chdir=${INFRA_PROVIDERS_DIR}/hetzner \
		init \
		-backend-config=organization="${TF_REMOTE_ORG}" \
		-backend-config=token="${TF_REMOTE_TOKEN}"
.PHONY: hetzner-init

hetzner-apply:
	PROVIDER=hetzner $(MAKE) .tf-apply
.PHONY: hetzner-apply

hetzner-plan:
	PROVIDER=hetzner $(MAKE) .tf-plan
.PHONY: hetzner-plan

hetzner-destroy:
	PROVIDER=hetzner $(MAKE) .tf-destroy
.PHONY: hetzner-destroy

save-kubeconfig:
	@mkdir -p ${HOME}/.kube

	@cd ./infrastructure/providers/${PROVIDER} && terraform output -json kubeconfig | jq -r > ${HOME}/.kube/config

	@echo "Kubeconfig saved to ${HOME}/.kube/config"
.PHONY: save-kubeconfig

# Extensible commands
.tf-apply:
	terraform \
		-chdir=${INFRA_PROVIDERS_DIR}/${PROVIDER} \
		apply

	$(MAKE) save-kubeconfig
.PHONY: .tf-apply

.tf-plan:
	terraform \
		-chdir=${INFRA_PROVIDERS_DIR}/${PROVIDER} \
		plan
.PHONY: .tf-plan

.tf-destroy:
	terraform \
		-chdir=${INFRA_PROVIDERS_DIR}/${PROVIDER} \
		destroy
.PHONY: .tf-destroy
