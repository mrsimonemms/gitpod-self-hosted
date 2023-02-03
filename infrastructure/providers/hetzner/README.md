# Hetzner

Build Gitpod infrastructure in Hetzner

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | >= 1.0.0, < 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | 1.36.2 |
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
| [hcloud_load_balancer_service.http](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_service.https](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_network.network](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network) | resource |
| [hcloud_network_subnet.network-subnet](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network_subnet) | resource |
| [hcloud_placement_group.vm](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/placement_group) | resource |
| [hcloud_ssh_key.vm](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key) | resource |
| [time_sleep.managers](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.nodes](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [hcloud_location.location](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/data-sources/location) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name Gitpod will be accessed on | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Data centre location - see https://docs.hetzner.com/cloud/general/locations for all available options | `string` | `"nbg1"` | no |
| <a name="input_size"></a> [size](#input\_size) | Deployment size | `string` | `"small"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
