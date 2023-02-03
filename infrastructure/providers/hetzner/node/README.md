# Node

Exists to allow for creation of multiple virtual machines

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | >= 1.0.0, < 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | >= 1.0.0, < 2.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [hcloud_server.virtual_machine](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_scale"></a> [auto\_scale](#input\_auto\_scale) | @todo(sje): implement auto scaling option | `bool` | `false` | no |
| <a name="input_cloud_init"></a> [cloud\_init](#input\_cloud\_init) | n/a | `any` | `null` | no |
| <a name="input_firewall"></a> [firewall](#input\_firewall) | n/a | `any` | n/a | yes |
| <a name="input_instances"></a> [instances](#input\_instances) | n/a | `number` | `1` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `any` | n/a | yes |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | n/a | `any` | n/a | yes |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | n/a | `any` | n/a | yes |
| <a name="input_server_type"></a> [server\_type](#input\_server\_type) | n/a | `any` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nodes"></a> [nodes](#output\_nodes) | Node information |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
