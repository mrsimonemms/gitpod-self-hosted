# Node

Exists to allow for creation of multiple virtual machines

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | >= 2.26.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | >= 2.26.0, < 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_droplet.virtual_machine](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_scale"></a> [auto\_scale](#input\_auto\_scale) | @todo(sje): implement auto scaling option | `bool` | `false` | no |
| <a name="input_cloud_init"></a> [cloud\_init](#input\_cloud\_init) | n/a | `any` | `null` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | variable "firewall" {} | `number` | `1` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `any` | n/a | yes |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | n/a | `any` | n/a | yes |
| <a name="input_server_type"></a> [server\_type](#input\_server\_type) | n/a | `any` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nodes"></a> [nodes](#output\_nodes) | Node information |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
