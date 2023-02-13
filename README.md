# Gitpod Self-Hosted

Resources for managing your own [Gitpod](https://www.gitpod.io) installation

<!-- toc -->

* [About](#about)
* [Infrastructure](#infrastructure)
* [Cluster Sizes](#cluster-sizes)
* [Supported Cloud Providers](#supported-cloud-providers)
* [Getting Started](#getting-started)
  * [Create Your Terraform](#create-your-terraform)
  * [Next Steps](#next-steps)
    * [Container Storage Interface (optional)](#container-storage-interface-optional)
    * [Cert-Manager](#cert-manager)
    * [Install Gitpod](#install-gitpod)
    * [Monitoring](#monitoring)
  * [Outputs](#outputs)
    * [`cert_manager`](#cert_manager)
    * [`domain_name`](#domain_name)
    * [`gitpod_config`](#gitpod_config)
    * [`gitpod_secrets`](#gitpod_secrets)
    * [`kubeconfig`](#kubeconfig)
  * [Example Gitpod Module - Hetzner](#example-gitpod-module---hetzner)
* [Versioning](#versioning)
* [Roadmap](#roadmap)
* [Support](#support)
* [Referral Links](#referral-links)

<!-- Regenerate with "pre-commit run -a markdown-toc" -->

<!-- tocstop -->

## About

> _Railway trains are impartial too. But if you lay down the lines for them,
> that's the way they go._
>
> **Bernard Woolley, Yes Minister**

From August 2021, I provided the technical leadership of the Gitpod Self-Hosted
team until [my redundancy in January 2023](https://www.gitpod.io/blog/building-for-the-long-run).
Even though Self-Hosted is no longer part of Gitpod's business strategy, I've done
too much good work on the project that I wasn't prepared to just let it die. Also,
I still maintain my own Gitpod instance that I enjoy hacking on.

The general aim of this project is to be railway tracks. The major issue that Gitpod
had when we supported self-hosting was that we aimed to support every cloud provider's
managed Kubernetes service which resulted in limiting what features Gitpod could
have. This project will have an intentionally limited number of things that you can
configure so that your installation works reliably.

In fact, by design this project will only allow you to configure five things:
1. The cloud you run it on
1. The domain name it's run on
1. The location it runs in
1. The size of the installation - `small` (for PoCs), `medium` and `large`
(see [Cluster Sizes](#cluster-sizes))
1. The SSH key used to access the virtual machines

A more detailed explanation and reasoning on why I'm still passionate about Gitpod
Self-Hosted is [on my blog](https://www.simonemms.com/blog/2023/02/05/self-hosted-is-dead-long-live-self-hosted).

## Infrastructure

This builds an infrastructure similar to the one that is used for [Gitpod.io](https://gitpod.io),
namely a [k3s](https://k3s.io) cluster running on [Ubuntu 20.04](https://releases.ubuntu.com/focal)
with all the required dependencies and packages. If the cloud provider supports it,
this will also use container registry, database and object storage to connect to
your Gitpod instance, or the in-cluster dependencies if not.

This is not designed to run on the managed Kubernetes service of a cloud provider.
That proved too difficult to do so reliably. Gitpod.io abandoned using GKE in mid-2022
because it was too difficult to get the full feature-set and our team made the mistake
of supporting all the managed Kubernetes providers. This project corrects that mistake
by using k3s-only.

**IMPORTANT** this is _NOT_ a good project for a Kubernetes beginner. Whilst I laud
any effort for self-improvement, Gitpod is not the project to do it on. I won't be
providing any general Kubernetes support in this repository.

## Cluster Sizes

There is a standard approach provided for the size of clusters. As this project is
designed to be railways tracks for installing Gitpod, the cluster size is the main
method of configuration. Any user-defined data is configured in the `size_data`
variable - there is limited validation on this parameter and will be ignored if
an unsupported `size` is usedl

| Name | Purpose | Manager Highly-Available | Manager Nodes | Worker Nodes | Worker Clusters |
| --- | --- | --- | --- | --- | --- |
| `small` | PoCs and personal developer environments | No | 1 x 4vCPU, 16GB RAM | 1 x 4vCPU, 16GB RAM | 1 |
| `medium` | Small development teams | Yes | 3 x [smallest usable machine](https://docs.k3s.io/installation/requirements#large-clusters) | 3-100 x 4vCPU, 16GB RAM | 1 |
| `large` | Large development teams | Yes | 3 x user-defined | Auto-scaled, user-defined  | User-defined |

The `large` cluster may not be supported in all cloud providers. This is dependent
upon the cloud provider having some form of auto-scaling ability for virtual machines.

In future, there may be support for `extra-large` clusters with support for a multi-region
installation for international development teams.

## Supported Cloud Providers

* [Hetzner](https://hetzner.cloud/?ref=UWVUhEZNkm6p)

## Getting Started

> You can check out my [Gitpod App](https://github.com/mrsimonemms/gitpod-app/)
> repo, which is the configuration for my own Gitpod installation.

### Create Your Terraform

This project expects you to have an understanding of how to use [Terraform](https://www.terraform.io/).

1. Create a new repository
1. Configure your desired [remote state](https://developer.hashicorp.com/terraform/language/state/remote)
1. Import the Gitpod Module for your desired cloud provider. This
is in the format `github.com/mrsimonemms/gitpod-self-hosted/infrastructure/providers/<provider>`
1. Add any additional Terraform resources you want. This will typically
be your DNS configuration, but may include container registry, database
and object storage if you don't wish to use the default configuration
(or if your desired provide doesn't have these services)
1. Configure your `cert_manager`, `domain_name`, `gitpod_config`,
`gitpod_secrets` and `kubeconfig` [outputs](https://developer.hashicorp.com/terraform/language/values/outputs).

### Next Steps

Once your Terraform resources have been applied, you will need to configure
your k3s instance and install Gitpod.

#### Container Storage Interface (optional)

A CSI driver is used to configure how the Kubernetes cluster saves persistent
data. k3s uses `local-path` storage by default, which saves the data to the
node. That's fine, but not necessarily performant and, if the node is evicted,
the data is lost.

For each of the providers, a CSI driver is given to save data to the cloud's
volume implementation.

Here's how to install the Hetzner CSI. Notice the `HCLOUD_TOKEN`, which is
required to manage volumes.

```shell
curl -sfSL https://raw.githubusercontent.com/mrsimonemms/gitpod-self-hosted/main/csi.sh | \
  CMD=hetzner \
  HCLOUD_TOKEN="${HCLOUD_TOKEN}" \
  bash -
```

This is an optional step, but strongly recommended.

#### Cert-Manager

This installs cert-manager with Helm, creates any secrets and configures the
ClusterIssuer you've defined in the Terraform output.

**NB** - the `SECRETS` and `CLUSTER_ISSUER` arguments must be encoded
as [Base64](https://en.wikipedia.org/wiki/Base64).

```shell
curl -sfSL https://raw.githubusercontent.com/mrsimonemms/gitpod-self-hosted/main/install.sh | \
  CMD=cert_manager \
  DOMAIN_NAME="$(terraform output -raw domain_name)" \
  SECRETS="$(terraform output -json cert_manager | jq -cr '.secrets | @base64')" \
  CLUSTER_ISSUER="$(terraform output -json cert_manager | jq -cr '.cluster_issuer | @base64')" \
  bash -
```

#### Install Gitpod

Installs or upgrades Gitpod.

**NB** - the `GITPOD_CONFIG` and `GITPOD_SECRETS` arguments must be encoded
as [Base64](https://en.wikipedia.org/wiki/Base64).

```shell
curl -sfSL https://raw.githubusercontent.com/mrsimonemms/gitpod-self-hosted/main/install.sh | \
  CMD=install_gitpod \
  GITPOD_CONFIG="$(terraform output -json gitpod_config | jq -cr '@base64')" \
  GITPOD_SECRETS="$(terraform output -json gitpod_secrets | jq -cr '@base64')" \
  bash -
```

#### Monitoring

This will also install the [MrSimonEmms/gitpod-monitoring](https://github.com/MrSimonEmms/gitpod-monitoring)
Helm chart to the `monitoring` namespace. This is designed to provide some
observability on your Gitpod instance. If you do not wish to install this
chart, please set the environment variable `MONITORING_INSTALL` to `false`.

### Outputs

#### `cert_manager`

Gitpod requires [cert-manager](https://cert-manager.io) as there
are various internal certificates generated. The `install.sh` script
also configures cert-manager to be your TLS issuer for your instance's
public certificates. Whilst Gitpod works fine with other issuers, this
project will only support cert-manager as the issuer. As Gitpod requires
a wildcard certificate, you must configure a [DNS01](https://cert-manager.io/docs/configuration/acme/dns01)
ClusterIssuer.

The `cert_manager` output must have two keys - `secrets` and
`cluster_issuer`. The `secrets` are the secrets required for the
ClusterIssuer to work. Each key is the secret name and the value is
key/value pairs of the secret name and secret value.

These secrets will be created in the `cert-manager` namespace.

The `cluster_issuer` is the Kubernetes manifest's `spec`. Check the
[cert-manager](https://cert-manager.io/docs/configuration/acme/dns01/#supported-dns01-providers)
documentation for your desired provider. Typically, this will be
configuring the DNS01 challenge provider to use the secret detailed
in `secrets`.

This is an example for [Cloudflare](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare)
configuration.

```terraform
output "cert_manager" {
  sensitive   = true
  value = {
    secrets = {
      cloudflare-solver = {
        apiToken = var.cloudflare_api_token
      }
    }
    cluster_issuer = {
      spec = {
        acme = {
          solvers = [
            {
              dns01 = {
                cloudflare = {
                  apiTokenSecretRef = {
                    name = "cloudflare-solver" # This is the secret referenced above
                    key  = "apiToken"
                  }
                }
              }
            }
          ]
        }
      }
    }
  }
}
```

#### `domain_name`

Output the `domain_name` that the instance lives behind. This
is in the format `gitpod.domain.com`.

```terraform
output "domain_name" {
  value       = var.domain_name
  sensitive   = true
}
```

#### `gitpod_config`

Output the Gitpod Installer configuration values in JSON format. This
will be used to override the default values.

At a minimum, this should set the `domain`, but can set other things.
See the [Gitpod documentation](https://github.com/gitpod-io/gitpod/blob/main/install/installer/pkg/config/v1/config.go)
for more details.

```terraform
output "gitpod_config" {
  value = {
    blockNewUsers = {
      enabled  = length(var.domain_passlist) > 0
      passlist = var.domain_passlist
    }
    domain = var.domain_name
  }
  sensitive = true
}
```

#### `gitpod_secrets`

These will be secrets that are required by the [`gitpod_config`](#gitpod_config).
Typically, these will be credentials for your database, registry, storage and
the like.

These secrets will be created in the `gitpod` namespace.

Like the [`cert_manager`](#cert_manager) output, these will have the secret
name as the top-level key and then any secrets as key/value pairs.

This example is how one might define the `database` secret for an Azure
MySQL database - this is based upon [an old project](https://github.com/mrsimonemms/gitpod-self-hosted-infrastructure/blob/main/infrastructure/azure/output.tf#L24)
as Azure is not yet supported by this project.

```terraform
output "gitpod_secrets" {
  value = {
    database = {
      # If unsure, use this key
      encryptionKeys = "[{\"name\":\"general\",\"version\":1,\"primary\":true,\"material\":\"4uGh1q8y2DYryJwrVMHs0kWXJlqvHWWt/KJuNi04edI=\"}]"
      host           = "${azurerm_mysql_server.db.0.name}.mysql.database.azure.com"
      password       = azurerm_mysql_server.db.0.administrator_login_password
      port           = 3306
      username       = "${azurerm_mysql_server.db.0.administrator_login}@${azurerm_mysql_server.db.0.name}"
    }
  }
  sensitive = true
}
```

#### `kubeconfig`

Pass the `kubeconfig` value from the provider module.

```terraform
output "kubeconfig" {
  value       = module.hetzner.kubeconfig
  sensitive   = true
}
```

### Example Gitpod Module - Hetzner

```terraform
module "hetzner" {
  source = "github.com/mrsimonemms/gitpod-self-hosted/infrastructure/providers/hetzner"

  domain_name          = var.domain_name
  location             = var.location
  size                 = var.size
  ssh_private_key_path = var.ssh_private_key_path
  ssh_public_key_path  = var.ssh_public_key_path
}
```

## Versioning

Gitpod currently uses [Werft](https://werft.dev) as their CI/CD system and publishes
images to [werft.gitpod-dev.com](https://werft.gitpod-dev.com). When I left Gitpod,
there was an RFC about switching from Werft to GitHub Actions. Watch this space for
more information.

This project maintains two tagged versions of the Installer:
- `nightly`: a daily version, generated from the most recent version at midnight
UTC. This is also tagged with a date tag, in format `YYYY-MM-DD`.
- `latest`: a monthly supported version. This is also tagged with a version tag,
in a semver-like format `YYYY.MM.<patch>`. It is recommended you use this.

To define your version, set the `GITPOD_INSTALLER_VERSION` environment variable.
If unset, it will be `latest`.

## Roadmap

The roadmap will largely depend upon the community response to this repository. Ideally,
I would like to see support for:
- Amazon Web Services
- Civo Cloud
- DigitalOcean
- Google Cloud Platform
- Microsoft Azure

Work on these platforms will cost money to get resources spun up. If you want me
to work on these for your own Gitpod installation, I will only be able to do so
if you can provide me an account to cover the cost of creating these resources
for testing purposes.

I'm happy to receive pull requests for these platforms from contributors. As above,
I will need to be able to test these before they're merged to `main` - pull requests
will only be accepted if they come with an account for the platform in question so
I can verify the work.

Please [contact me](https://www.simonemms.com/contact) to discuss further.

## Support

I'm happy to discuss options for commercial support contracts. Please
[contact me](https://www.simonemms.com/contact) to discuss further.

## Referral Links

Using these links will help support the project and provide you with additional
credits for the cloud provider.

* [Hetzner](https://hetzner.cloud/?ref=UWVUhEZNkm6p)
