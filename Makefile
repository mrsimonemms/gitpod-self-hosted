EXAMPLES_DIR = ./examples

hetzner-init:
# Hetzner uses Terraform Cloud as the backend, so need to specify the workspace name
	terraform \
		-chdir=${EXAMPLES_DIR}/hetzner \
		init \
		-backend-config=organization="${TF_REMOTE_ORG}" \
		-backend-config=token="${TF_REMOTE_TOKEN}"
.PHONY: hetzner-init

hetzner-apply:
	terraform \
		-chdir=${EXAMPLES_DIR}/hetzner \
		apply

	PROVIDER=hetzner $(MAKE) save-kubeconfig
.PHONY: hetzner-apply

hetzner-plan:
	terraform \
		-chdir=${EXAMPLES_DIR}/hetzner \
		plan
.PHONY: hetzner-plan

hetzner-destroy:
	terraform \
		-chdir=${EXAMPLES_DIR}/hetzner \
		destroy
.PHONY: hetzner-destroy

save-kubeconfig:
	@mkdir -p ${HOME}/.kube

	@cd ${EXAMPLES_DIR}/${PROVIDER} && terraform output -json kubeconfig | jq -r > ${HOME}/.kube/config

	@echo "Kubeconfig saved to ${HOME}/.kube/config"
.PHONY: save-kubeconfig
