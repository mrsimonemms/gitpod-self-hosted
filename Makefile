EXAMPLES_DIR = ./examples
CHART_DIR = chart/gitpod

cert-manager:
	@bash ./install.sh cert_manager \
		"$(shell terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -raw domain_name)" \
		"$(shell terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -json cert_manager | jq -cr '.secrets | @base64')" \
		"$(shell terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -json cert_manager | jq -cr '.cluster_issuer | @base64')"
.PHONY: cert-manager

kube-gitpod:
	@kubectl get pods -n gitpod --sort-by=.metadata.name
.PHONY: kube-gitpod

install-gitpod:
	@bash ./install.sh install_gitpod \
		"$(shell terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -json gitpod_config | jq -cr '@base64')" \
		"$(shell terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -json gitpod_secrets | jq -cr '@base64')"
.PHONY: install-gitpod

save-kubeconfig:
	@mkdir -p ${HOME}/.kube

	@cd ${EXAMPLES_DIR}/${PROVIDER} && terraform output -json kubeconfig | jq -r > ${HOME}/.kube/config
	@chmod 600 ${HOME}/.kube/config

	@echo "Kubeconfig saved to ${HOME}/.kube/config"
.PHONY: save-kubeconfig

tls-backup:
	@kubectl get secret -n gitpod https-certificates -o yaml > ./https-certificates.yaml
.PHONY: tls-backup

tls-restore:
	@kubectl delete secret -n gitpod https-certificates || true
	@kubectl apply -f ./https-certificates.yaml
.PHONY: tls-restore

###
# Providers
###

azure-init:
	@terraform \
		-chdir=${EXAMPLES_DIR}/azure \
		init \
		-backend-config=resource_group_name="${TF_STATE_AZURE_RESOURCE_GROUP}" \
		-backend-config=storage_account_name="${TF_STATE_AZURE_ACCOUNT_NAME}" \
		-backend-config=container_name="${TF_STATE_AZURE_CONTAINER_NAME}" \
		-backend-config=key="${TF_STATE_AZURE_KEY}"
.PHONY: azure-init

azure-apply:
	@terraform \
		-chdir=${EXAMPLES_DIR}/azure \
		apply

	PROVIDER=azure $(MAKE) save-kubeconfig cert-manager install-gitpod
.PHONY: azure-apply

azure-destroy:
	@terraform \
		-chdir=${EXAMPLES_DIR}/azure \
		destroy
.PHONY: azure-destroy

hetzner-init:
	@terraform \
		-chdir=${EXAMPLES_DIR}/hetzner \
		init \
		-backend-config=organization="${TF_REMOTE_ORG}" \
		-backend-config=token="${TF_REMOTE_TOKEN}"
.PHONY: hetzner-init

hetzner-apply:
	@terraform \
		-chdir=${EXAMPLES_DIR}/hetzner \
		apply

	PROVIDER=hetzner $(MAKE) save-kubeconfig
	@bash ./csi.sh hetzner
	PROVIDER=hetzner $(MAKE) cert-manager install-gitpod
.PHONY: hetzner-apply

hetzner-destroy:
	@terraform \
		-chdir=${EXAMPLES_DIR}/hetzner \
		destroy
.PHONY: hetzner-destroy
