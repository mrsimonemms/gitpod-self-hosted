# Hetzner

Build Gitpod infrastructure in Hetzner

<!-- toc -->

* [Requirements](#requirements)
* [Providers](#providers)
* [Modules](#modules)
* [Resources](#resources)
* [Inputs](#inputs)
* [Outputs](#outputs)

<!-- Regenerate with "pre-commit run -a markdown-toc" -->

<!-- tocstop -->

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
| [hcloud_load_balancer.k3s_managers](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer) | resource |
| [hcloud_load_balancer.load_balancer](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer) | resource |
| [hcloud_load_balancer_network.k3s_manager_subnet](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_network) | resource |
| [hcloud_load_balancer_network.network_subnet](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_network) | resource |
| [hcloud_load_balancer_service.http](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_service.https](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_service.k3s_ssh](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_service.kubernetes](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_service.ssh](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_target.k3s_managers](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_target) | resource |
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
| <a name="input_size_data"></a> [size\_data](#input\_size\_data) | Additional data for deployment size - this will be ignored if using an invalid 'size' | <pre>object({<br>    node_count = number<br>  })</pre> | <pre>{<br>  "node_count": 3<br>}</pre> | no |
| <a name="input_ssh_private_key_path"></a> [ssh\_private\_key\_path](#input\_ssh\_private\_key\_path) | Path to private key, used for logging in to VM - passphrases are not supported | `string` | `"~/.ssh/id_rsa"` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to public key, used for logging in to VM - passphrases are not supported | `string` | `"~/.ssh/id_rsa.pub"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_records"></a> [dns\_records](#output\_dns\_records) | n/a |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubernetes config YAML file |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
