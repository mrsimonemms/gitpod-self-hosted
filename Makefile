EXAMPLES_DIR = ./examples

cert-manager:
	@echo "Installing cert-manager"

	@helm upgrade \
		--atomic \
		--cleanup-on-fail \
		--create-namespace \
		--install \
		--namespace cert-manager \
		--repo https://charts.jetstack.io \
		--reset-values \
		--set installCRDs=true \
		--set 'extraArgs={--dns01-recursive-nameservers-only=true,--dns01-recursive-nameservers=8.8.8.8:53\,1.1.1.1:53}' \
		--version ^1.11.0 \
		--wait \
		cert-manager cert-manager

	@echo "Installed cert-manager"

	@mkdir -p tmp

	@echo "Creating ClusterIssuer"
	@for row in $(shell terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -json cert_manager | jq -r '.secrets' | jq -c '.[] | @base64'); do \
		echo "$$row" | base64 -d | jq -r '.name'; \
		kubectl create secret generic $$(echo "$$row" | base64 -d | jq -r '.name') \
			-n cert-manager \
			--from-literal=$$(echo "$$row" | base64 -d | jq -r '.key')=$$(echo "$$row" | base64 -d | jq -r '.value') \
			--dry-run=client -o yaml | \
			kubectl replace --force -f - ; \
	done

	@terraform \
		-chdir=${EXAMPLES_DIR}/${PROVIDER} \
		output -json cert_manager | jq -r '.cluster_issuer' > tmp/cert_manager_spec.yaml

	@yq -P '. *= load("tmp/cert_manager_spec.yaml")' kubernetes/cert-manager.yaml | kubectl apply -f -
	@echo "ClusterIssuer created"

	@echo "Creating TLS certificate"

	@terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -json domain_name | jq -r > tmp/domain_name

	@yq e -o json '.spec.dnsNames=["$(shell cat tmp/domain_name)", "*.$(shell cat tmp/domain_name)", "*.ws.$(shell cat tmp/domain_name)"]' \
		./kubernetes/tls-certificate.yaml | kubectl apply -f -

	@echo "TLS certificate created"
.PHONY: cert-manager

save-kubeconfig:
	@mkdir -p ${HOME}/.kube

	@cd ${EXAMPLES_DIR}/${PROVIDER} && terraform output -json kubeconfig | jq -r > ${HOME}/.kube/config
	chmod 600 ${HOME}/.kube/config

	@echo "Kubeconfig saved to ${HOME}/.kube/config"

	kubectl create namespace gitpod || true
.PHONY: save-kubeconfig

###
# Providers
###

hetzner-init:
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

	PROVIDER=hetzner $(MAKE) save-kubeconfig cert-manager
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
