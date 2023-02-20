# Azure

Build Gitpod infrastructure in Azure

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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.43.0, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.43.0, < 4.0.0 |

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
| [azurerm_lb.load_balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.load_balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.load_balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.load_balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_network_security_group.network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.load_balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_subnet.network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azurerm_user_assigned_identity_id"></a> [azurerm\_user\_assigned\_identity\_id](#input\_azurerm\_user\_assigned\_identity\_id) | Azure identity to associate with the node - this gives the virtual machines access to specific resources | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name Gitpod will be accessed on | `string` | n/a | yes |
| <a name="input_kubecontext"></a> [kubecontext](#input\_kubecontext) | Kubecontext name to use | `string` | `"gitpod-self-hosted"` | no |
| <a name="input_location"></a> [location](#input\_location) | Data centre location - run `az account list-locations -o table` for all available options | `string` | `"uksouth"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to locate all resources | `string` | n/a | yes |
| <a name="input_size"></a> [size](#input\_size) | Deployment size | `string` | `"small"` | no |
| <a name="input_size_data"></a> [size\_data](#input\_size\_data) | Additional data for deployment size - this will be ignored if using an invalid 'size' | `object({})` | `{}` | no |
| <a name="input_ssh_private_key_path"></a> [ssh\_private\_key\_path](#input\_ssh\_private\_key\_path) | Path to private key, used for logging in to VM - passphrases are not supported | `string` | `"~/.ssh/id_rsa"` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to public key, used for logging in to VM - passphrases are not supported | `string` | `"~/.ssh/id_rsa.pub"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_records"></a> [dns\_records](#output\_dns\_records) | n/a |
| <a name="output_k3s_token"></a> [k3s\_token](#output\_k3s\_token) | Join token for k3s |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubernetes config YAML file |
| <a name="output_kubecontext"></a> [kubecontext](#output\_kubecontext) | Kubecontext name to use |
| <a name="output_network_security_group_id"></a> [network\_security\_group\_id](#output\_network\_security\_group\_id) | Network security group the virtual machines are located in |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
