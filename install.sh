#!/usr/bin/env bash

set -eo pipefail

trap 'catch $?' EXIT

USE_REMOTE_SCRIPT=0
if [ -z "${BASH_SOURCE:-}" ]; then
  # Will get files remotely
  cmd="${CMD:-}"
  USE_REMOTE_SCRIPT=1
else
  # Will get files locally
  cmd="${1:-}"
fi

mkdir -p ./tmp

export GITPOD_INSTALLER_VERSION="${GITPOD_INSTALLER_VERSION:-main.6378}" # @todo(sje): autodiscover the "latest"
KUBECONFIG="${KUBECONFIG:-${HOME}/.kube/config}"
NAMESPACE="gitpod"
SSH_HOST_KEY_SECRET="ssh-gateway-host-key"
REPO_RAW_URL="${REPO_RAW_URL:-https://raw.githubusercontent.com/MrSimonEmms/gitpod-self-hosted/main}"

# Create the Gitpod namespace
kubectl create namespace "${NAMESPACE}" || true

###########
# Scripts #
###########

catch() {
  if [ "${1}" = "0" ]; then
    echo "Script successful"
  else
    echo "Script failed"
  fi
  exit "${1}"
}

cert_manager() {
  echo "Installing cert-manager"
  cm_namespace="cert-manager"

  domain_name="${1}"
  secrets="${2}"
  cluster_issuer="${3}"

  helm upgrade \
		--atomic \
		--cleanup-on-fail \
		--create-namespace \
		--install \
		--namespace "${cm_namespace}" \
		--repo https://charts.jetstack.io \
		--reset-values \
		--set installCRDs=true \
		--set 'extraArgs={--dns01-recursive-nameservers-only=true,--dns01-recursive-nameservers=8.8.8.8:53\,1.1.1.1:53}' \
		--version ^1.11.0 \
		--wait \
		cert-manager cert-manager

  echo "Creating secrets for the ClusterIssuer"

  for row in $(echo "${secrets}" | jq -r '.[] | @base64'); do
    secret="$(echo "${row}" | base64 -d)"

    kubectl create secret generic "$(echo "${secret}" | jq -r '.name')" \
      -n "${cm_namespace}" \
      --from-literal="$(echo "${secret}" | jq -r '.key')=$(echo "${secret}" | jq -r '.value')" \
      --dry-run=client \
      -o yaml | \
      kubectl replace --force -f -
  done

  echo "Creating ClusterIssuer"

  echo "${cluster_issuer}" > tmp/cluster_issuer.yaml
  yq -P '. *= load("tmp/cluster_issuer.yaml")' "$(get_file kubernetes/cert-manager.yaml)" | kubectl apply -f -
  rm -f tmp/cluster_issuer.yaml

  echo "Creating TLS certificate for ${domain_name}"
  yq e \
    ".spec.dnsNames=[\"${domain_name}\", \"*.${domain_name}\", \"*.ws.${domain_name}\"]" \
	  "$(get_file kubernetes/tls-certificate.yaml)" | kubectl apply -f -
}

get_file() {
  TARGET="${1}"
  if [ "${USE_REMOTE_SCRIPT}" -eq 1 ]; then
    # Download file to temp dir
    OUT="${TMPDIR:-/tmp}/${TARGET}"
    mkdir -p "$(dirname "${OUT}")"
    curl -sSfL "${REPO_RAW_URL}/${TARGET}" -o "${OUT}"
    echo "${OUT}"
  else
    # Read file from disk
    echo "${TARGET}"
  fi
}

install_gitpod() {
  echo "Installing Gitpod"

  chart_dir="tmp/chart"

  gitpod_config="${1}"
  # gitpod_secrets="${2}" # @todo(sje): incorporate secrets into build

  # Generate SSH private key
  rm -f tmp/ssh-key*
  ssh-keygen -t rsa -N "" -C "Gitpod SSH key" -f tmp/ssh-key

  echo "${gitpod_config}" > tmp/generated_config.yaml
	yq -P '. *= load("tmp/generated_config.yaml")' "$(get_file kubernetes/gitpod.config.yaml)" > tmp/gitpod.config.yaml

  mkdir -p ${chart_dir}/templates
  cp "$(get_file chart/gitpod/Chart.yaml)" ${chart_dir}/Chart.yaml
  kubectl create secret generic \
    "${SSH_HOST_KEY_SECRET}" \
    --from-file="host-key=./tmp/ssh-key" \
    -n "${NAMESPACE}" \
    --dry-run=client \
    -o yaml | \
    kubectl replace --force -f -

  ./bin/gitpod-installer validate config -c tmp/gitpod.config.yaml
  ./bin/gitpod-installer validate cluster -n "${NAMESPACE}" --kubeconfig="${KUBECONFIG}" -c tmp/gitpod.config.yaml
  ./bin/gitpod-installer render -n "${NAMESPACE}" -c tmp/gitpod.config.yaml > ${chart_dir}/templates/gitpod.yaml

  # Escape any Golang template variables
  # shellcheck disable=SC2016
	sed -i -r 's/(.*\{\{.*)/{{`\1`}}/' "${chart_dir}/templates/gitpod.yaml"

  yq e -P -i ".appVersion = \"${GITPOD_INSTALLER_VERSION}\"" "${chart_dir}/Chart.yaml"

  stop_running_workspaces

  # If certificate secret already exists, set the timeout to 5m
  cert_secret=$(kubectl get secrets -n "${NAMESPACE}" https-certificates -o jsonpath='{.metadata.name}' || echo '')
  helm_timeout="5m"
  if [ "${cert_secret}" = "" ]; then
    helm_timeout="1h"
  fi

  echo "Installing Gitpod with Helm with ${helm_timeout} timeout"
  helm upgrade \
    --atomic \
    --cleanup-on-fail \
    --create-namespace \
    --install \
    --namespace="${NAMESPACE}" \
    --reset-values \
    --timeout "${helm_timeout}" \
    --wait \
    gitpod \
    tmp/chart

  echo "Gitpod available on https://$(yq '.domain' tmp/gitpod.config.yaml)"
}

stop_running_workspaces() {
  echo "Shutting down running workspaces"

  context_namespace="$(kubectl config view --minify | yq '.contexts[].context.namespace // "default"')"

  # Change the namespace on the context as gpctl doesn't have a namespace flag
  kubectl config set-context --current --namespace="${NAMESPACE}"

  for instance in $(ENTRYPOINT=/app/gpctl ./bin/gitpod-installer workspaces list -o json | jq -r 'select(. != null) | .[] | .Instance'); do
    echo "Shutting down workspace ${instance}"
    if ENTRYPOINT=/app/gpctl ./bin/gitpod-installer workspaces stop "${instance}"; then
      echo "Shutdown ${instance} successfully"
    else
      echo "Retrying shutdown ${instance}"
      sleep 10
      ENTRYPOINT=/app/gpctl ./bin/gitpod-installer workspaces stop "${instance}"
    fi
  done

  # Reset the namespace
  kubectl config set-context --current --namespace="${context_namespace}"
}

############
# Commands #
############

case "${cmd}" in
  cert_manager )
    cert_manager "${DOMAIN_NAME:-$2}" "$(echo "${SECRETS:-$3}" | base64 -d)" "$(echo "${CLUSTER_ISSUER:-$4}" | base64 -d)"
    ;;
  install_gitpod )
    install_gitpod "$(echo "${GITPOD_CONFIG:-$2}" | base64 -d)" "$(echo "${GITPOD_SECRETS:-$3}" | base64 -d)"
    ;;
  stop_running_workspaces )
    stop_running_workspaces
    ;;
  * )
    echo "Unknown command: ${cmd}"
    exit 1
    ;;
esac
