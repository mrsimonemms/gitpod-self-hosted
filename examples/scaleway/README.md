# Azure

How to run Gitpod on [Scaleway](https://scaleway.com)

## Architecture

- Gitpod running in Scaleway Private Network
- Scaleway Load balancer created as an ingress gateway
- Domain name configured in Scaleway DNS


## Getting started

This example assumes you have a domain zone in the Scaleway DNS settings

Import an SSH key into Scaleway if you've not already.

export SCW_ACCESS_KEY and SCW_SECRET_KEY for the project you are using

create a .auto.tfvars file

```
size = "medium"
subdomain = "my"
domain_name = "gitpod-domain.com"
project_id = "<scaleway project id uuid>"
zone = "<the zone you want to deploy in>"
region = "<the region you want to deploy in>"
```

```
terraform apply
terraform output -raw kubeconfig > kubetest
KUBECONFIG=~/.kube/config:./kubetest kubectl config view --flatten >/tmp/config
mv /tmp/config ~/.kube/config
```

`kubectl get pods` should return a valid response.

