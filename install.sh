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

CLEANUP_FAILED_UPGRADE="${CLEANUP_FAILED_UPGRADE:-true}"
DOCKER_PULL="${DOCKER_PULL:-always}"
GITPOD_IMAGE_SOURCE="${GITPOD_IMAGE_SOURCE:-ghcr.io/mrsimonemms/gitpod-self-hosted/installer}"
GITPOD_INSTALLER_VERSION="${GITPOD_INSTALLER_VERSION:-latest}"
HELM_TIMEOUT="${HELM_TIMEOUT:-5m}"
KUBECONFIG="${KUBECONFIG:-${HOME}/.kube/config}"
KUBE_TEMPLATES_DIR="${KUBE_TEMPLATES_DIR:-}" # Optionally add custom templates into the Helm directory
MONITORING_INSTALL="${MONITORING_INSTALL:-true}"
MONITORING_NAMESPACE="monitoring"
NAMESPACE="gitpod"
REPO_RAW_URL="${REPO_RAW_URL:-https://raw.githubusercontent.com/MrSimonEmms/gitpod-self-hosted/main}"
SSH_HOST_KEY_SECRET="ssh-gateway-host-key"
TLS_CERT_ISSUE_TIMEOUT="${TLS_CERT_ISSUE_TIMEOUT:-15m}"

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

  create_kube_secrets "${secrets}" "${cm_namespace}"

  echo "Creating ClusterIssuer"

  echo "${cluster_issuer}" > tmp/cluster_issuer.yaml
  yq -P '. *= load("tmp/cluster_issuer.yaml")' "$(get_file kubernetes/cert-manager.yaml)" | kubectl apply -f -
  rm -f tmp/cluster_issuer.yaml

  echo "Creating TLS certificate for ${domain_name}"
  yq e \
    ".spec.dnsNames=[\"${domain_name}\", \"*.${domain_name}\", \"*.ws.${domain_name}\"]" \
    "$(get_file kubernetes/tls-certificate.yaml)" | kubectl apply -f -

  echo "Waiting ${TLS_CERT_ISSUE_TIMEOUT} for Gitpod TLS certificate to be issued..."
  kubectl wait \
    --for=condition=ready \
    -n gitpod \
    --timeout="${TLS_CERT_ISSUE_TIMEOUT}" \
    certificate \
    https-certificates
}

create_kube_secrets() {
  secrets="${1}"
  target_namespace="${2:-$NAMESPACE}"

  for secretName in $(echo "${secrets}" | jq -r 'keys[]'); do
    secretList="$(echo "${secrets}" | jq --arg KEY "${secretName}" '.[$KEY]')"

    keyValuePairs="$(echo "${secretList}" | jq -r 'to_entries | .[] | @base64')"

    create_cmd="kubectl create secret generic ${secretName}"
    create_cmd+=" -n ${target_namespace}"
    create_cmd+=" --dry-run=client"
    create_cmd+=" -o yaml"

    for pair in $keyValuePairs; do
      key="$(echo "${pair}" | base64 -d | jq -r '.key')"
      value="$(echo "${pair}" | base64 -d | jq -r '.value')"

      create_cmd+=" --from-literal=${key}='${value}'"
    done

    eval "${create_cmd}" | kubectl replace --force -f -
  done
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

installer() {
  # Check docker is available
  which docker > /dev/null || (echo "Docker not installed - see https://docs.docker.com/engine/install" && exit 1)

  # Now, run the Installer
  docker run --rm \
    -v="${KUBECONFIG}:${HOME}/.kube/config" \
    -v="${KUBECONFIG}:/root/.kube/config" \
    -v="${PWD}:${PWD}" \
    -w="${PWD}" \
    --pull="${DOCKER_PULL}" \
    --entrypoint="${ENTRYPOINT:-/app/installer}" \
    "${GITPOD_IMAGE_SOURCE}:${GITPOD_INSTALLER_VERSION}" \
    "${@}"
}

install_gitpod() {
  echo "Installing Gitpod"

  chart_dir="tmp/chart"

  gitpod_config="${1}"
  gitpod_secrets="${2}"

  create_kube_secrets "${gitpod_secrets}"

  # Generate SSH private key
  if ! kubectl get secret -n "${NAMESPACE}" "${SSH_HOST_KEY_SECRET}"; then
    rm -f tmp/ssh-key*
    ssh-keygen -t rsa -N "" -C "Gitpod SSH key" -f tmp/ssh-key

    kubectl create secret generic \
      "${SSH_HOST_KEY_SECRET}" \
      --from-file="host-key=./tmp/ssh-key" \
      -n "${NAMESPACE}"
  fi

  echo "${gitpod_config}" > tmp/generated_config.yaml
  yq -P '. *= load("tmp/generated_config.yaml")' "$(get_file kubernetes/gitpod.config.yaml)" > tmp/gitpod.config.yaml

  rm -Rf "${chart_dir}/templates"
  mkdir -p "${chart_dir}/templates"
  cp "$(get_file chart/gitpod-self-hosted/Chart.yaml)" ${chart_dir}/Chart.yaml

  # Allow adding custom Kubernetes resources in the Helm templates
  if [ -n "${KUBE_TEMPLATES_DIR}" ]; then
    echo "Copying custom templates - ${KUBE_TEMPLATES_DIR}/*.yml"
    find "${KUBE_TEMPLATES_DIR}" -type f -name "*.yml" -exec cp {} "${chart_dir}/templates" \;

    echo "Copying custom templates - ${KUBE_TEMPLATES_DIR}/*.yaml"
    find "${KUBE_TEMPLATES_DIR}" -type f -name "*.yaml" -exec cp {} "${chart_dir}/templates" \;
  fi

  installer validate config -c tmp/gitpod.config.yaml
  installer validate cluster -n "${NAMESPACE}" --kubeconfig="${HOME}/.kube/config" -c tmp/gitpod.config.yaml
  installer render -n "${NAMESPACE}" -c tmp/gitpod.config.yaml > "${chart_dir}/templates/gitpod.yaml"

  post_process "${chart_dir}/templates/gitpod.yaml"

  # Escape any Golang template variables
  # shellcheck disable=SC2016
  sed -i -r 's/(.*\{\{.*)/{{`\1`}}/' "${chart_dir}/templates/gitpod.yaml"

  yq e -P -i ".appVersion = \"$(installer version | jq -r '.version')\"" "${chart_dir}/Chart.yaml"

  stop_running_workspaces

  echo "Installing Gitpod with Helm with ${HELM_TIMEOUT} timeout"
  helm upgrade \
    --atomic="${CLEANUP_FAILED_UPGRADE}" \
    --cleanup-on-fail="${CLEANUP_FAILED_UPGRADE}" \
    --create-namespace \
    --install \
    --namespace="${NAMESPACE}" \
    --reset-values \
    --timeout "${HELM_TIMEOUT}" \
    --wait \
    gitpod \
    tmp/chart

  echo "Gitpod available on https://$(yq '.domain' tmp/gitpod.config.yaml)"

  if [ "${MONITORING_INSTALL}" = "true" ]; then
    echo "Installing monitoring"
    helm upgrade \
      --atomic \
      --cleanup-on-fail \
      --create-namespace \
      --install \
      --namespace="${MONITORING_NAMESPACE}" \
      --repo=https://helm.simonemms.com \
      --reset-values \
      --set gitpodNamespace="${NAMESPACE}" \
      --wait \
      monitoring \
      gitpod-monitoring
  fi
}

post_process() {
  target="${1}"

  # If using in-cluster registry, disable remote persistence as the volume can get locked on Helm upgrade
  yq eval-all --inplace \
    '(select(.kind == "PersistentVolumeClaim" and .metadata.name == "registry") | .spec.storageClassName) = "local-path"' \
    "${target}"
}

stop_running_workspaces() {
  echo "Shutting down running workspaces"

  context_namespace="$(kubectl config view --minify | yq '.contexts[].context.namespace // "default"')"

  # Change the namespace on the context as gpctl doesn't have a namespace flag
  kubectl config set-context --current --namespace="${NAMESPACE}"

  for instance in $(ENTRYPOINT=/app/gpctl installer workspaces list -o json | jq -r 'select(. != null) | .[] | .Instance'); do
    echo "Shutting down workspace ${instance}"
    if ENTRYPOINT=/app/gpctl installer workspaces stop "${instance}"; then
      echo "Shutdown ${instance} successfully"
    else
      echo "Retrying shutdown ${instance}"
      sleep 10
      ENTRYPOINT=/app/gpctl installer workspaces stop "${instance}"
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
