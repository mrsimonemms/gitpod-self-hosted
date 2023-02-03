EXAMPLES_DIR = ./examples
NAMESPACE = gitpod
GITPOD_INSTALLER_VERSION ?= main.6378
CHART_DIR = chart/gitpod

build-gitpod:
	@$(shell mkdir -p ${CHART_DIR}/templates tmp)

	@$(shell terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -json gitpod_config | jq -r > tmp/generated_config.yaml)

	@yq -P '. *= load("tmp/generated_config.yaml")' kubernetes/gitpod.config.yaml > tmp/gitpod.config.yaml
	@$(MAKE) installer ARGS="validate config -c tmp/gitpod.config.yaml"
	@$(MAKE) installer ARGS="validate cluster -n ${NAMESPACE} --kubeconfig='${HOME}/.kube/config' -c tmp/gitpod.config.yaml"
	@$(MAKE) -s installer ARGS="render -n ${NAMESPACE} -c tmp/gitpod.config.yaml" > ${CHART_DIR}/templates/gitpod.yaml

# Escape any Golang template variables
	@sed -i -r 's/(.*\{\{.*)/{{`\1`}}/' "${CHART_DIR}/templates/gitpod.yaml"

	@rm -Rf tmp/chart
	@cp -rf ${CHART_DIR} tmp/chart
	@yq e -P -i '.appVersion = "${GITPOD_INSTALLER_VERSION}"' tmp/chart/Chart.yaml

	@echo "Installing Gitpod with Helm"
	@helm upgrade \
        --atomic \
        --cleanup-on-fail \
        --create-namespace \
        --install \
        --namespace="${NAMESPACE}" \
        --reset-values \
        --timeout "10m" \
        --wait \
        gitpod \
        tmp/chart

	@echo "Gitpod available on https://$(shell yq '.domain' tmp/gitpod.config.yaml)"
.PHONY: build-gitpod

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

	@$(shell terraform -chdir=${EXAMPLES_DIR}/${PROVIDER} output -json domain_name | jq -r > tmp/domain_name)

	@echo "Creating TLS certificate for $(shell cat tmp/domain_name)"

	@yq e -o json '.spec.dnsNames=["$(shell cat tmp/domain_name)", "*.$(shell cat tmp/domain_name)", "*.ws.$(shell cat tmp/domain_name)"]' \
		./kubernetes/tls-certificate.yaml | kubectl apply -f -

	@echo "TLS certificate created"
.PHONY: cert-manager

installer:
	@GITPOD_INSTALLER_VERSION=${GITPOD_INSTALLER_VERSION} ./bin/gitpod-installer ${ARGS}
.PHONY: installer

save-kubeconfig:
	@mkdir -p ${HOME}/.kube

	@cd ${EXAMPLES_DIR}/${PROVIDER} && terraform output -json kubeconfig | jq -r > ${HOME}/.kube/config
	chmod 600 ${HOME}/.kube/config

	@echo "Kubeconfig saved to ${HOME}/.kube/config"

	@kubectl create namespace ${NAMESPACE} || true
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

	PROVIDER=hetzner $(MAKE) save-kubeconfig cert-manager build-gitpod
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
