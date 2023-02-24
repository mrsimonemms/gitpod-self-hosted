# DigitalOcean

How to run Gitpod on [Hetzner](https://m.do.co/c/1a9f2c34bfb4)

## Architecture

- Gitpod running in DigitalOcean
- In-cluster dependencies
- Database running in-cluster as DO only provides MySQL 8 and
[Gitpod requires MySQL 5.7](https://github.com/gitpod-io/gitpod/issues/4890)
- Domain name configured in Cloudflare - subdomains added automatically
