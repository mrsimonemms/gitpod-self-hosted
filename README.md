# Gitpod Self-Hosted

> This is a work-in-progress

Resources for managing your own [Gitpod](https://www.gitpod.io) installation

<!-- toc -->

* [Supported Cloud Providers](#supported-cloud-providers)
* [Configuration](#configuration)
* [Open in Gitpod](#open-in-gitpod)
* [Open in devbox](#open-in-devbox)

<!-- Regenerate with "pre-commit run -a markdown-toc" -->

<!-- tocstop -->

## Supported Cloud Providers

* [Hetzner](./infrastructure/providers/hetzner)

## Configuration

> At the moment, this is a single cloud provider but it's built with multiple instances
> in mind

The configuration is common across cloud providers. Using
[environment variables](https://www.gitpod.io/docs/configure/projects/environment-variables#user-specific-environment-variables)
is recommended.

* `domain_name` - the domain name you wish to deploy to, eg `gitpod.domain.com`
* `location` - the location where the resources will be built. The values are dependent
upon the cloud provider
* `size` - can choose between `small`, `medium` and `large` (only `small` is currently
supported)

## Open in Gitpod

* [Open in Gitpod](https://gitpod.io/from-referrer/)

## Open in devbox

* `curl -fsSL https://get.jetpack.io/devbox | bash`
* `devbox shell`
