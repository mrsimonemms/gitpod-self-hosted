#!/usr/bin/env bash

set -eo pipefail

if [ -z "${BASH_SOURCE:-}" ]; then
  # Will get files remotely
  cmd="${CMD:-}"
else
  # Will get files locally
  cmd="${1:-}"
fi

HETZNER_CSI_VERSION="${HETZNER_CSI_VERSION:-2.1.1}"

###########
# Scripts #
###########

set_local_path_not_default() {
  kubectl annotate storageclasses.storage.k8s.io local-path "storageclass.kubernetes.io/is-default-class=false" --overwrite
}

hetzner() {
  echo "Creating CSI driver for Hetzner"

  hcloud_token="${1}"

  kubectl create secret generic hcloud \
    -n kube-system \
    --from-literal="token=${hcloud_token}" \
    --dry-run=client \
    -o yaml | \
    kubectl replace --force -f -

  set_local_path_not_default

  kubectl apply -f "https://raw.githubusercontent.com/hetznercloud/csi-driver/v${HETZNER_CSI_VERSION}/deploy/kubernetes/hcloud-csi.yml"
}

############
# Commands #
############

case "${cmd}" in
  azure )
    echo "Warning: Azure has no supported CSI driver"
    ;;
  hetzner )
    hetzner "${HCLOUD_TOKEN:-$2}"
    ;;
  * )
    echo "Unknown command: ${cmd}"
    exit 1
    ;;
esac
