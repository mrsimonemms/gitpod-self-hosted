# Scaleway Provider

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.10.0 |
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
| [random_integer.label_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [scaleway_lb.main](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/lb) | resource |
| [scaleway_lb_backend.http-backend](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/lb_backend) | resource |
| [scaleway_lb_backend.https-backend](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/lb_backend) | resource |
| [scaleway_lb_backend.ssh-backend](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/lb_backend) | resource |
| [scaleway_lb_frontend.http-frontend](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/lb_frontend) | resource |
| [scaleway_lb_frontend.https-frontend](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/lb_frontend) | resource |
| [scaleway_lb_frontend.ssh-frontend](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/lb_frontend) | resource |
| [scaleway_lb_ip.main](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/lb_ip) | resource |
| [scaleway_vpc_gateway_network.main](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_gateway_network) | resource |
| [scaleway_vpc_private_network.network](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_private_network) | resource |
| [scaleway_vpc_public_gateway.pg01](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_public_gateway) | resource |
| [scaleway_vpc_public_gateway_dhcp.dhcp01](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_public_gateway_dhcp) | resource |
| [scaleway_vpc_public_gateway_ip.gw01](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_public_gateway_ip) | resource |
| [scaleway_vpc_public_gateway_pat_rule.main](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_public_gateway_pat_rule) | resource |
| [time_sleep.managers](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The top level domain name Gitpod will be accessed on | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Data centre location - see https://docs.hetzner.com/cloud/general/locations for all available options | `string` | `"nbg1"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Your project ID. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The Scaleway Region | `string` | n/a | yes |
| <a name="input_size"></a> [size](#input\_size) | Deployment size | `string` | `"small"` | no |
| <a name="input_ssh_private_key_path"></a> [ssh\_private\_key\_path](#input\_ssh\_private\_key\_path) | Path to private key, used for logging in to VM - passphrases are not supported. Needs to be registered with Scaleway for access. | `string` | `"~/.ssh/id_rsa"` | no |
| <a name="input_subdomain"></a> [subdomain](#input\_subdomain) | The subdomain, if any, Gitpod will be accessed on | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The Scaleway Zone | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_records"></a> [dns\_records](#output\_dns\_records) | n/a |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubernetes config YAML file |
