# Hetzner

Build Gitpod infrastructure in Hetzner

<!-- toc -->

* [Quickstart](#quickstart)
* [Terraform State](#terraform-state)
* [Requirements](#requirements)
* [Providers](#providers)
* [Modules](#modules)
* [Resources](#resources)
* [Inputs](#inputs)
* [Outputs](#outputs)

<!-- Regenerate with "pre-commit run -a markdown-toc" -->

<!-- tocstop -->

## Quickstart

> [Setting environment variables in Gitpod](https://www.gitpod.io/docs/configure/projects/environment-variables#user-specific-environment-variables)

1. [Open this repo in Gitpod](https://gitpod.io/from-referrer/)
2. [Generate a Hetzner API token](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token) and save this to an environment variable called `HCLOUD_TOKEN`
3. Save your desired domain name to an environment variable called `TF_VAR_domain_name`
4. Run `make hetzner-init hetzner-apply`

## Terraform State

As there is no Terraform remote state for Hetzner and Hetzner doesn't have
an S3-compatible storage, this provider is configured to use Terraform Cloud.

You need to set a `TF_REMOTE_ORG` envvar with your organisation name
(eg, `my-org-name`) and a `TF_REMOTE_TOKEN` envvar with your [Terraform Cloud
API token](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/api-tokens).

This provider uses local modules which are incompatible with Terraform Cloud
runners so you will need to set the `Execution Mode` to `Local`
[[1](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings#execution-mode)]

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | >= 1.0.0, < 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | 1.36.2 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | 0.9.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common"></a> [common](#module\_common) | ../../modules/common | n/a |
| <a name="module_k3s_manager"></a> [k3s\_manager](#module\_k3s\_manager) | ./node | n/a |
| <a name="module_k3s_nodes"></a> [k3s\_nodes](#module\_k3s\_nodes) | ./node | n/a |
| <a name="module_k3s_setup"></a> [k3s\_setup](#module\_k3s\_setup) | ../../modules/k3s | n/a |

## Resources

| Name | Type |
|------|------|
| [hcloud_firewall.firewall](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
| [hcloud_load_balancer.load_balancer](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer) | resource |
| [hcloud_load_balancer_network.network-subnet](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_network) | resource |
| [hcloud_load_balancer_service.http](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_service.https](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_service.ssh](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_target.servers](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_target) | resource |
| [hcloud_network.network](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network) | resource |
| [hcloud_network_subnet.network-subnet](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network_subnet) | resource |
| [hcloud_placement_group.vm](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/placement_group) | resource |
| [hcloud_ssh_key.vm](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key) | resource |
| [random_integer.label_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [time_sleep.managers](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [hcloud_location.location](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/data-sources/location) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name Gitpod will be accessed on | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Data centre location - see https://docs.hetzner.com/cloud/general/locations for all available options | `string` | `"nbg1"` | no |
| <a name="input_size"></a> [size](#input\_size) | Deployment size | `string` | `"small"` | no |
| <a name="input_ssh_private_key_path"></a> [ssh\_private\_key\_path](#input\_ssh\_private\_key\_path) | Path to private key, used for logging in to VM - passphrases are not supported | `string` | `"~/.ssh/id_rsa"` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to public key, used for logging in to VM - passphrases are not supported | `string` | `"~/.ssh/id_rsa.pub"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_records"></a> [dns\_records](#output\_dns\_records) | n/a |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubernetes config YAML file |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
