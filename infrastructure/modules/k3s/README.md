# k3s

Install k3s

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | >=2.6.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | >=2.6.0, < 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ssh_resource.install_additional_managers](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [ssh_resource.install_primary_manager](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [ssh_sensitive_resource.k3s_token](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/sensitive_resource) | resource |
| [ssh_sensitive_resource.kubeconfig](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/sensitive_resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubecontext"></a> [kubecontext](#input\_kubecontext) | n/a | `string` | `"gitpod-self-hosted"` | no |
| <a name="input_load_balancer_address"></a> [load\_balancer\_address](#input\_load\_balancer\_address) | n/a | `string` | `null` | no |
| <a name="input_managers"></a> [managers](#input\_managers) | n/a | <pre>list(object({<br>    node = object({<br>      name       = string<br>      public_ip  = string<br>      private_ip = string<br>      username   = string<br>    })<br>    labels       = map(bool)<br>    private_key  = string<br>    bastion_host = optional(string)<br>    bastion_port = optional(string)<br>    bastion_user = optional(string)<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_ports"></a> [firewall\_ports](#output\_firewall\_ports) | n/a |
| <a name="output_k3s_token"></a> [k3s\_token](#output\_k3s\_token) | n/a |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | n/a |
| <a name="output_kubecontext"></a> [kubecontext](#output\_kubecontext) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
