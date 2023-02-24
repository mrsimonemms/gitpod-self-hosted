DEV_CERTS_DIR = ./tmp/certs
EXAMPLES_DIR = ./examples

cert-manager:
	$(MAKE) tls-list

	@bash ./install.sh cert_manager \
		"$(shell terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -raw domain_name)" \
		"$(shell terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -json cert_manager | jq -cr '.secrets | @base64')" \
		"$(shell terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -json cert_manager | jq -cr '.cluster_issuer | @base64')"
.PHONY: tls-list

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

	@terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -json kubeconfig | jq -r > ${HOME}/.kube/config.gsh
	@KUBECONFIG="${HOME}/.kube/config:${HOME}/.kube/config.gsh" kubectl config view --flatten > ${HOME}/.kube/config.tmp

	@mv ${HOME}/.kube/config.tmp ${HOME}/.kube/config
	@rm -f ${HOME}/.kube/config.gsh

	@chmod 600 ${HOME}/.kube/config

	@kubectl config use-context "$(shell terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -json kubecontext | jq -r)"

	@echo "Kubeconfig saved to ${HOME}/.kube/config"
.PHONY: save-kubeconfig

tls-backup:
	@kubectl get secret -n gitpod https-certificates -o yaml > ./https-certificates.yaml
.PHONY: tls-backup

# Take the certs and convert them to the envvar value
# Designed to be used as "gp env CERTS_LIST=$(make tls-envvar)"
tls-envvar:
	@rm -Rf ./tmp/cert-list.yaml
	@touch ./tmp/cert-list.yaml
	@for cert in $(shell ls ${DEV_CERTS_DIR}); do \
		echo "$$(echo $$cert | sed -e 's/.yaml//'): $$(cat ${DEV_CERTS_DIR}/$$cert | base64 -w0)" >> ./tmp/cert-list.yaml; \
	done

	@cat ./tmp/cert-list.yaml | base64 -w0
.PHONY: tls-envvar

# TLS certs can be stored in CERTS_LIST envvar - this is a convenience for development
# and not a substitute for a production environment
tls-list:
	@echo "Loading certs saved to this workspace"

	@kubectl create namespace gitpod || true

	@kubectl apply -f ${DEV_CERTS_DIR}/$(shell terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -raw domain_name).yaml || true
.PHONY: tls-list

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

digitalocean-init:
	@terraform \
		-chdir=${EXAMPLES_DIR}/digitalocean \
		init \
		-backend-config=organization="${TF_REMOTE_ORG}" \
		-backend-config=token="${TF_REMOTE_TOKEN}"
.PHONY: digitalocean-init

digitalocean-apply:
	@terraform \
		-chdir=${EXAMPLES_DIR}/digitalocean \
		apply

	PROVIDER=digitalocean $(MAKE) save-kubeconfig cert-manager install-gitpod
.PHONY: digitalocean-apply

digitalocean-destroy:
	@terraform \
		-chdir=${EXAMPLES_DIR}/digitalocean \
		destroy
.PHONY: digitalocean-destroy

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

	PROVIDER=hetzner $(MAKE) save-kubeconfig cert-manager install-gitpod
.PHONY: hetzner-apply

hetzner-destroy:
	@terraform \
		-chdir=${EXAMPLES_DIR}/hetzner \
		destroy
.PHONY: hetzner-destroy

scaleway-init:
	@terraform \
		-chdir=${EXAMPLES_DIR}/scaleway \
		init \
		-backend-config=organization="${TF_REMOTE_ORG}" \
		-backend-config=token="${TF_REMOTE_TOKEN}"
.PHONY: scaleway-init

scaleway-apply:
	@terraform \
		-chdir=${EXAMPLES_DIR}/scaleway \
		apply

	PROVIDER=scaleway $(MAKE) save-kubeconfig cert-manager install-gitpod
.PHONY: scaleway-apply

scaleway-destroy:
	@terraform \
		-chdir=${EXAMPLES_DIR}/scaleway \
		destroy
.PHONY: scaleway-destroy
